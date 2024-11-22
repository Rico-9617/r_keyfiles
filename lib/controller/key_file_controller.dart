import 'dart:async';
import 'dart:io';

import 'package:kdbx_lib/kdbx.dart';
import 'package:path/path.dart' as p;
import 'package:r_backup_tool/main.dart';
import 'package:r_backup_tool/model/kdbx_file_wrapper.dart';
import 'package:r_backup_tool/repo/key_store_repo.dart';
import 'package:r_backup_tool/utils/encrypt_tool.dart';
import 'package:uuid/uuid.dart';

import 'kdbx_file_controller_mixin.dart';

class KeyFileController with KdbxFileControllerMixin {
  Stream<KdbxFileWrapper?> parseKdbxFile(File kdbxFile, String psw,
      {bool externalFile = false}) {
    final streamController = StreamController<KdbxFileWrapper?>();
    Future<void> parse() async {
      final data = KdbxFileWrapper(kdbxFile.path, externalStore: externalFile);
      final newId = EncryptTool.md5String(kdbxFile.path);
      final savedFiles = await KeyStoreRepo.instance.getSavedFiles();
      for (final saved in savedFiles) {
        if (newId == saved.split('@')[2]) {
          streamController.addError('文件已存在!');
          streamController.add(null);
          await streamController.close();
          return;
        }
      }
      final result = await KeyStoreRepo.instance
          .decryptKdbxFile(data, psw)
          .handleError((e) {
        streamController.addError(e);
      }).single;
      if (!result) {
        streamController.add(null);
        await streamController.close();
        return;
      }

      savedFiles.add(
          '${data.title.value}@$externalFile@${newId}@${EncryptTool.encrypt(data.path, psw)}');
      await KeyStoreRepo.instance.saveFiles(savedFiles);

      KeyStoreRepo.instance.savedKeyFiles.addItem(data);
      KeyStoreRepo.instance.currentFile.value = data;
      streamController.add(data);
      await streamController.close();
    }

    parse();
    return streamController.stream;
  }

  Future<String?> createNewKeyFile(String name, String psw) async {
    try {
      final keyFile = KeyStoreRepo.instance.kdbxFormat
          .create(Credentials(ProtectedValue.fromString(psw)), name);
      final folder = (await KeyStoreRepo.instance.getInternalFolder()).path;
      File internalFile = File(p.join(folder, '${name}.kdbx'));
      while (await internalFile.exists()) {
        internalFile = File(p.join(
            folder, '${name}_${DateTime.now().millisecondsSinceEpoch}.kdbx'));
      }
      final wrapper = KdbxFileWrapper(internalFile.path);
      wrapper.kdbxFile = keyFile;
      wrapper.encrypted.value = false;
      final saveResult = await KeyStoreRepo.instance.saveKeyStore(wrapper);
      if (saveResult != null) return saveResult;
      wrapper.id = const Uuid().v4();
      final savedFiles = await KeyStoreRepo.instance.getSavedFiles();
      savedFiles.add(
          '$name@false@${wrapper.id}@${EncryptTool.encrypt(wrapper.path, psw)}');
      await KeyStoreRepo.instance.saveFiles(savedFiles);
      wrapper.title.value = name;
      wrapper.rootGroup =
          KdbxGroupWrapper(group: keyFile.body.rootGroup, rootGroup: true);
      KeyStoreRepo.instance.savedKeyFiles.addItem(wrapper);
      KeyStoreRepo.instance.currentFile.value = wrapper;
      return null;
    } catch (e) {
      logger.e(e);
    }
    return '创建失败';
  }
}
