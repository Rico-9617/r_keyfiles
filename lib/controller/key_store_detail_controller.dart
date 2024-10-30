import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:kdbx_lib/kdbx.dart';
import 'package:path/path.dart' as p;
import 'package:r_backup_tool/main.dart';
import 'package:r_backup_tool/model/kdbx_file_wrapper.dart';
import 'package:r_backup_tool/repo/key_store_repo.dart';
import 'package:r_backup_tool/utils/encrypt_tool.dart';

class KeyStoreDetailController {
  Stream<bool> decodeSavedFile(KdbxFileWrapper fileWrapper, String psw) {
    final streamController = StreamController<bool>();
    Future<void> parse() async {
      try {
        fileWrapper.path = EncryptTool.decrypt(fileWrapper.path, psw);
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
        streamController.addError(e);
        streamController.add(false);
        await streamController.close();
      } catch (e) {
        if (kDebugMode) {
          print('restparse decode error: $e');
        }
        streamController.addError('解析失败!');
        streamController.add(false);
        await streamController.close();
      }
    }

    parse();
    return streamController.stream;
  }

  Future<String?> modifyKeyFilePassword(
      KdbxFileWrapper fileWrapper, String psw) async {
    if (fileWrapper.kdbxFile == null) return '文件未解锁';
    fileWrapper.kdbxFile!.credentials =
        Credentials(ProtectedValue.fromString(psw));
    final saveResult = await KeyStoreRepo.instance.saveKeyStore(fileWrapper);
    if (saveResult != null) return saveResult;

    await KeyStoreRepo.instance.updateSavedFiles(fileWrapper, (data) {
      data[3] = EncryptTool.encrypt(fileWrapper.path, psw);
      return data;
    });
    return null;
  }

  Future<String?> modifyKeyStoreTitle(
      KdbxFileWrapper fileWrapper, String title) async {
    if (fileWrapper.kdbxFile == null) return '修改失败';
    if (!fileWrapper.kdbxFile!.body.rootGroup.name.set(title)) return '修改失败';
    final saveResult = await KeyStoreRepo.instance.saveKeyStore(fileWrapper);
    if (saveResult != null) return saveResult;

    await KeyStoreRepo.instance.updateSavedFiles(fileWrapper, (data) {
      data[0] = title;
      return data;
    });
    fileWrapper.title.value = title;
    return null;
  }

  Future<String?> importExternalKeyStore(
      KdbxFileWrapper fileWrapper, String psw) async {
    try {
      final folder = (await KeyStoreRepo.instance.getInternalFolder()).path;
      File internalFile = File(p.join(folder, fileWrapper.title.value));
      while (await internalFile.exists()) {
        internalFile = File(p.join(folder,
            '${fileWrapper.title.value}_${DateTime.now().millisecondsSinceEpoch}'));
      }
      logger.d(internalFile.path);
      await File(fileWrapper.path).copy(internalFile.path);
      await KeyStoreRepo.instance.updateSavedFiles(fileWrapper, (data) {
        data[1] = 'false';
        data[3] = EncryptTool.encrypt(internalFile.path, psw);
        logger.d(data.join('@'));
        return data;
      });
      fileWrapper.path = internalFile.path;
      fileWrapper.externalStore.value = false;
      logger.d(fileWrapper.path);
      return null;
    } catch (e) {
      logger.e(e);
    }
    return '导入失败';
  }

  deleteKeyStore(KdbxFileWrapper fileWrapper) async {
    await KeyStoreRepo.instance.deleteKeyStore(fileWrapper);
  }
}
