import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:kdbx_lib/kdbx.dart';
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

  void modifyKeyFilePassword(KdbxFileWrapper fileWrapper, String psw) {
    if (fileWrapper.kdbxFile == null) return;
    fileWrapper.kdbxFile!.credentials =
        Credentials(ProtectedValue.fromString(psw));
  }

  modifyKeyStoreTitle(KdbxFileWrapper fileWrapper, String title) async {
    if (fileWrapper.kdbxFile == null) return;
    fileWrapper.kdbxFile!.body.rootGroup.name.set(title);

    await fileWrapper.kdbxFile!
      ..saveTo((bytes) async {
        return bytes;
      });
    final savedList = await KeyStoreRepo.instance.getSavedFiles();
    for (int index = 0; index < savedList.length; index++) {
      final arr = savedList[index].split('@');
      if (arr[2] == fileWrapper.id) {
        arr[0] = title;
        savedList[index] = arr.join('@');
        KeyStoreRepo.instance.saveFiles(savedList);
        break;
      }
    }
    fileWrapper.title.value = title;
  }

  deleteKeyStore(KdbxFileWrapper fileWrapper) async {
    await KeyStoreRepo.instance.deleteKeyStore(fileWrapper);
  }
}
