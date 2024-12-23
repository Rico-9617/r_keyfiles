import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:kdbx_lib/kdbx.dart';
import 'package:path/path.dart' as p;
import 'package:r_backup_tool/main.dart';
import 'package:r_backup_tool/model/kdbx_file_wrapper.dart';
import 'package:r_backup_tool/repo/key_store_repo.dart';
import 'package:r_backup_tool/utils/native_tool.dart';

import 'kdbx_file_controller_mixin.dart';

class KeyStoreDetailController with KdbxFileControllerMixin {
  const KeyStoreDetailController();

  Stream<bool> decodeSavedFile(KdbxFileWrapper fileWrapper, String psw) {
    final streamController = StreamController<bool>();
    Future<void> parse() async {
      try {
        final path = String.fromCharCodes(base64Decode(fileWrapper.path));
        fileWrapper.path = path;
        final file = File(fileWrapper.path);
        if (await file.exists()) {
          await streamController.addStream(
              KeyStoreRepo.instance.decryptKdbxFile(fileWrapper, psw));
          await streamController.close();
        } else {
          streamController.addError(const PathNotFoundException('', OSError()));
          streamController.add(false);
          await streamController.close();
        }
      } on PathNotFoundException catch (e) {
        logger.e(e);
        streamController.addError(e);
        streamController.add(false);
        await streamController.close();
      } catch (e) {
        logger.e(e);
        streamController.addError('解析失败!');
        streamController.add(false);
        await streamController.close();
      }
    }

    parse();
    return streamController.stream;
  }

  lockFile(KdbxFileWrapper fileWrapper) async {
    fileWrapper.encrypted.value = true;
    final savedList = await KeyStoreRepo.instance.getSavedFiles();
    for (int index = 0; index < savedList.length; index++) {
      final arr = savedList[index].split('@');
      if (arr[2] == fileWrapper.id) {
        fileWrapper.path = arr[3];
        break;
      }
    }
    fileWrapper.rootGroup = null;
    fileWrapper.kdbxFile = null;
  }

  Future<String?> modifyKeyFilePassword(
      KdbxFileWrapper fileWrapper, String psw) async {
    if (fileWrapper.kdbxFile == null) return '文件未解锁';
    fileWrapper.kdbxFile!.credentials =
        Credentials(ProtectedValue.fromString(psw));
    final saveResult = await KeyStoreRepo.instance.saveKeyStore(fileWrapper);
    if (saveResult != null) return saveResult;

    await KeyStoreRepo.instance.updateSavedFiles(fileWrapper, (data) {
      final result = base64Encode(fileWrapper.path.codeUnits);
      if (result.isEmpty) {
        throw Exception();
      } else {
        data[3] = result;
      }
      return data;
    });
    return null;
  }

  deleteKeyStore(KdbxFileWrapper fileWrapper) async {
    await KeyStoreRepo.instance.deleteKeyStore(fileWrapper);
  }

  Future<String?> exportKeyStore(KdbxFileWrapper fileWrapper) async {
    try {
      final outputDir =
          Directory(p.join((await getDownloadDirectory()), 'key_backup'));
      if (!await outputDir.exists()) {
        await outputDir.create();
      }
      final outputFile =
          File(p.join(outputDir.path, '${fileWrapper.title.value}.kdbx'));
      await outputFile.writeAsBytes(await fileWrapper.kdbxFile!.save(),
          flush: true);
      return null;
    } catch (e) {
      logger.e(e);
    }
    return '导出失败';
  }
}
