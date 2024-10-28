import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:kdbx_lib/kdbx.dart';
import 'package:r_backup_tool/foundation/list_value_notifier.dart';
import 'package:r_backup_tool/model/kdbx_file_wrapper.dart';
import 'package:r_backup_tool/repo/local_repo.dart';

class KeyStoreRepo {
  KeyStoreRepo._();

  static KeyStoreRepo? _instance;

  static KeyStoreRepo get instance {
    _instance ??= KeyStoreRepo._();
    return _instance!;
  }

  final savedKeyFiles = ListValueNotifier<KdbxFileWrapper>([]);
  final ValueNotifier<KdbxFileWrapper?> currentFile =
      ValueNotifier<KdbxFileWrapper?>(null);

  loadSavedFiles() async {
    final savedFiles = await getSavedFiles();
    if (savedFiles.isEmpty) return;
    savedKeyFiles.value = List.generate(savedFiles.length, (index) {
      final item = savedFiles[index].toString().split('@');
      final file = KdbxFileWrapper(item[3], externalStore: bool.parse(item[1]));
      file.title.value = item[0];
      file.id = item[2];
      print('testchange load saved file $index ${item}');
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
        final kdbx = await KdbxFormat().read(
            File(fileWrapper.path).readAsBytesSync(),
            Credentials(ProtectedValue.fromString(psw)));
        print('restparse body.rootGroup: ${kdbx.body.rootGroup.name.get()}');
        print('restparse body.rootGroup: ${kdbx.body.rootGroup}');
        fileWrapper.kdbxFile = kdbx;
        fileWrapper.title.value = kdbx.body.rootGroup.name.get() ?? 'Unnamed';

        fileWrapper.entities.value = kdbx.body.rootGroup.entries
            .map((e) => KdbxEntryWrapper(entry: e))
            .toList();
        fileWrapper.encrypted.value = false;
        streamController.add(true);
      } on KdbxInvalidKeyException {
        streamController.addError('密码错误!');
        streamController.add(false);
      } on PathNotFoundException catch (e) {
        streamController.addError(e);
        streamController.add(false);
        await streamController.close();
      } catch (e) {
        if (kDebugMode) {
          print('restparse error: ${e}');
        }
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

    if (!fileWrapper.externalStore) {
      await File(fileWrapper.path).delete();
    }

    KeyStoreRepo.instance.savedKeyFiles.removeItem(fileWrapper);
    if (KeyStoreRepo.instance.currentFile.value?.id == fileWrapper.id) {
      KeyStoreRepo.instance.currentFile.value =
          KeyStoreRepo.instance.savedKeyFiles.value.firstOrNull;
    }
  }

  Future<List<String>> getSavedFiles() async =>
      [...(await LocalRepo.instance.getStrings('_k_files') ?? List.empty())];

  saveFiles(List<String> datas) {
    LocalRepo.instance.saveStrings('_k_files', datas);
  }
}
