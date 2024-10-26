import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:kdbx_lib/kdbx.dart';
import 'package:r_backup_tool/model/kdbx_file_wrapper.dart';
import 'package:r_backup_tool/repo/local_repo.dart';
import 'package:r_backup_tool/utils/encrypt_tool.dart';

class KeyStoreRepo {
  final savedKeyFiles = ValueNotifier(List<KdbxFileWrapper>.empty());
  final currentFile = ValueNotifier<KdbxFileWrapper?>(null);

  loadSavedFiles() async {
    final savedFiles = await LocalRepo.instance.getStringList('_k_files');
    if (savedFiles == null || savedFiles.isEmpty()) return;
    savedKeyFiles.value = List.generate(savedFiles.length, (index) {
      final item = savedFiles[index].toString().split('@');
      final file = KdbxFileWrapper(item[1]);
      file.title.value = item[0];
      if (index == 0) {
        currentFile.value = file;
      }
      return file;
    });
  }

  Stream decodeSavedFile(String path, String psw) {
    final streamController = StreamController();
    Future<void> parse() async {
      try {
        final file = File(EncryptTool.decrypt(path, psw));
        if (await file.exists()) {
          streamController.addStream(parseKdbxFile(file, psw));
        } else {
          streamController.addError(const PathNotFoundException('', OSError()));
        }
      } catch (e) {
        if (kDebugMode) {
          print('restparse decode error: $e');
        }
        streamController.addError('解析失败!');
      }
      await streamController.close();
    }

    parse();
    return streamController.stream;
  }

  Stream<bool> parseKdbxFile(File kdbxFile, String psw) {
    final streamController = StreamController<bool>();
    Future<void> parse() async {
      try {
        final kdbx = await KdbxFormat().read(kdbxFile.readAsBytesSync(),
            Credentials(ProtectedValue.fromString(psw)));
        print('restparse body.rootGroup: ${kdbx.body.rootGroup.name.name}');
        print('restparse body.rootGroup: ${kdbx.body.rootGroup}');
        final data = KdbxFileWrapper(kdbxFile.path);
        data.title.value = kdbx.body.rootGroup.name.name;

        // final savedFiles = await LocalRepo.instance.getStringList('_k_files');
        // savedFiles.add('${data.title.value}@${EncryptTool.encrypt(data.path, psw)}');
        // LocalRepo.instance.saveStrings('_k_files',savedFiles);
        data.entities.value = kdbx.body.rootGroup.entries
            .map((e) => KdbxEntryWrapper(entry: e))
            .toList();

        streamController.add(true);
      } on KdbxInvalidKeyException {
        streamController.addError('密码错误!');
        streamController.add(false);
      } catch (e) {
        if (kDebugMode) {
          print('restparse error: ${e}');
        }
        streamController.addError('解析失败');
        streamController.add(false);
      }
      await streamController.close();
    }

    parse();
    return streamController.stream;
  }
}
