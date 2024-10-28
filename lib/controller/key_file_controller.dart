import 'dart:async';
import 'dart:io';

import 'package:r_backup_tool/model/kdbx_file_wrapper.dart';
import 'package:r_backup_tool/repo/key_store_repo.dart';
import 'package:r_backup_tool/utils/encrypt_tool.dart';
import 'package:uuid/uuid.dart';

class KeyFileController {
  Stream<bool> parseKdbxFile(File kdbxFile, String psw,
      {bool externalFile = false}) {
    final streamController = StreamController<bool>();
    Future<void> parse() async {
      final data = KdbxFileWrapper(kdbxFile.path, externalStore: externalFile);
      final result = await KeyStoreRepo.instance
          .decryptKdbxFile(data, psw)
          .handleError((e) {
        print('testchange parse file errorr $e');
        streamController.addError(e);
      }).single;
      print('testchange parse file ${result}  ${data.path}');
      if (!result) {
        streamController.add(false);
        await streamController.close();
        return;
      }

      final savedFiles = await KeyStoreRepo.instance.getSavedFiles();
      savedFiles.add(
          '${data.title.value}@$externalFile@${const Uuid().v4()}@${EncryptTool.encrypt(data.path, psw)}');
      KeyStoreRepo.instance.saveFiles(savedFiles);

      KeyStoreRepo.instance.savedKeyFiles.addItem(data);
      KeyStoreRepo.instance.currentFile.value = data;
      streamController.add(true);
      await streamController.close();

      print(
          'testchange parse file  saved ${KeyStoreRepo.instance.currentFile.value?.encrypted.value}');
    }

    parse();
    return streamController.stream;
  }
}
