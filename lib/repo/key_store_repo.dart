import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:kdbx_lib/kdbx.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:r_backup_tool/foundation/list_value_notifier.dart';
import 'package:r_backup_tool/main.dart';
import 'package:r_backup_tool/model/kdbx_file_wrapper.dart';
import 'package:r_backup_tool/repo/local_repo.dart';

class KeyStoreRepo {
  KeyStoreRepo._();

  static KeyStoreRepo? _instance;

  static KeyStoreRepo get instance {
    _instance ??= KeyStoreRepo._();
    return _instance!;
  }

  final kdbxFormat = KdbxFormat();
  final savedKeyFiles = ListValueNotifier<KdbxFileWrapper>([]);
  final ValueNotifier<KdbxFileWrapper?> currentFile =
      ValueNotifier<KdbxFileWrapper?>(null);

  loadSavedFiles() async {
    final savedFiles = await getSavedFiles();
    logger.d(savedFiles);
    if (savedFiles.isEmpty) return;
    savedKeyFiles.value = List.generate(savedFiles.length, (index) {
      final item = savedFiles[index].toString().split('@');
      logger.d(savedFiles[index]);
      final file = KdbxFileWrapper(item[3], externalStore: bool.parse(item[1]));
      file.title.value = item[0];
      file.id = item[2];
      if (index == 0) {
        currentFile.value = file;
      }
      return file;
    });
  }

  Stream<bool> decryptKdbxFile(KdbxFileWrapper fileWrapper, String psw) {
    final streamController = StreamController<bool>();
    Future<void> decrypt() async {
      try {
        final kdbx = await kdbxFormat.read(
            File(fileWrapper.path).readAsBytesSync(),
            Credentials(ProtectedValue.fromString(psw)));
        fileWrapper.kdbxFile = kdbx;
        fileWrapper.title.value = kdbx.body.rootGroup.name.get() ?? 'Unnamed';
        fileWrapper.rootGroup =
            KdbxGroupWrapper(group: kdbx.body.rootGroup, rootGroup: true);
        fileWrapper.encrypted.value = false;
        streamController.add(true);
      } on KdbxInvalidKeyException {
        streamController.addError('密码错误!');
        streamController.add(false);
      } on PathNotFoundException catch (e) {
        logger.e(e);
        streamController.addError(e);
        streamController.add(false);
        await streamController.close();
      } catch (e) {
        logger.e(e);
        streamController.addError('解析失败');
        streamController.add(false);
      }
      await streamController.close();
    }

    decrypt();
    return streamController.stream;
  }

  deleteKeyStore(KdbxFileWrapper fileWrapper) async {
    final savedFiles = await getSavedFiles();
    for (final saved in savedFiles) {
      if (saved.split('@')[2] == fileWrapper.id) {
        savedFiles.remove(saved);
        break;
      }
    }
    saveFiles(savedFiles);

    if (!fileWrapper.externalStore.value) {
      await File(fileWrapper.path).delete();
    }

    KeyStoreRepo.instance.savedKeyFiles.removeItem(fileWrapper);
    if (KeyStoreRepo.instance.currentFile.value?.id == fileWrapper.id) {
      KeyStoreRepo.instance.currentFile.value =
          KeyStoreRepo.instance.savedKeyFiles.value.firstOrNull;
    }
  }

  Future<List<String>> getSavedFiles() async {
    final conf = await LocalRepo.instance.getConfigFile(name: '.ks');
    final content = String.fromCharCodes(await conf.readAsBytes());
    return content.isEmpty
        ? []
        : String.fromCharCodes(await conf.readAsBytes()).split('<kf>');
  }

  saveFiles(List<String> dataList) async {
    final conf = await LocalRepo.instance.getConfigFile(name: '.ks');
    dataList.removeWhere((e) => e.isEmpty);
    conf.writeAsBytes(dataList.join('<kf>').codeUnits, flush: true);
  }

  updateSavedFiles(KdbxFileWrapper fileWrapper,
      List<String> Function(List<String> target) onUpdate) async {
    final savedList = await KeyStoreRepo.instance.getSavedFiles();
    for (int index = 0; index < savedList.length; index++) {
      final arr = savedList[index].split('@');
      if (arr[2] == fileWrapper.id) {
        savedList[index] = onUpdate(arr).join('@');
        KeyStoreRepo.instance.saveFiles(savedList);
        break;
      }
    }
  }

  Future<Directory> getInternalFolder() async {
    final folder = Directory(
        p.join((await getApplicationDocumentsDirectory()).path, '.kf'));
    if (!await folder.exists()) {
      await folder.create();
    }
    return folder;
  }

  Future<String?> saveKeyStore(KdbxFileWrapper fileWrapper) async {
    if (fileWrapper.externalStore.value) {
      return '外部文件无法保存';
    }
    if (fileWrapper.encrypted.value || fileWrapper.kdbxFile == null) {
      return '文件未解锁';
    }
    try {
      final fileData = await fileWrapper.kdbxFile!.save();
      await File(fileWrapper.path).writeAsBytes(fileData, flush: true);
      return null;
    } catch (e) {
      logger.e(e);
    }
    return '保存失败';
  }

  bool isUnderRecycleBin(KdbxGroupWrapper groupWrapper) {
    if (isRecycleBin(groupWrapper.group)) {
      return true;
    } else if (groupWrapper.parent != null) {
      return isUnderRecycleBin(groupWrapper.parent!);
    }
    return false;
  }

  bool isRecycleBin(KdbxGroup group) {
    return group == group.file.recycleBin;
  }
}
