import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:r_backup_tool/main.dart';
import 'package:r_backup_tool/model/kdbx_file_wrapper.dart';
import 'package:r_backup_tool/repo/key_store_repo.dart';

mixin KdbxFileControllerMixin {
  Future<String?> importExternalKeyStore(KdbxFileWrapper fileWrapper,
      {bool save = true}) async {
    try {
      final folder = (await KeyStoreRepo.instance.getInternalFolder()).path;
      File internalFile =
          File(p.join(folder, '${fileWrapper.title.value}.kdbx'));
      while (await internalFile.exists()) {
        internalFile = File(p.join(folder,
            '${fileWrapper.title.value}_${DateTime.now().millisecondsSinceEpoch}.kdbx'));
      }
      await File(fileWrapper.path).copy(internalFile.path);
      if (save) {
        await KeyStoreRepo.instance.updateSavedFiles(fileWrapper, (data) {
          final result = base64Encode(internalFile.path.codeUnits);
          if (result.isEmpty) {
            throw Exception();
          } else {
            data[3] = result;
          }
          data[1] = false.toString();
          return data;
        });
      }

      fileWrapper.path = internalFile.path;
      fileWrapper.externalStore.value = false;
      return null;
    } catch (e) {
      logger.e(e);
    }
    return '导入失败';
  }
}
