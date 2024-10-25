import 'package:flutter/cupertino.dart';
import 'package:r_backup_tool/model/kdbx_file_wrapper.dart';
import 'package:r_backup_tool/repo/local_repo.dart';

class KeyStoreRepo {
  final savedKeyFiles = ValueNotifier(List<KdbxFileWrapper>.empty());
  final currentFile = ValueNotifier<KdbxFileWrapper?>(null);

  loadSavedFiles() async {
    final savedNames = await LocalRepo.instance.getStringList('_k_names');
    final savedFiles = await LocalRepo.instance.getStringList('_k_files');
    if (savedFiles == null || savedFiles.isEmpty()) return;
    savedKeyFiles.value = List.generate(savedFiles.length, (index) {
      final file = KdbxFileWrapper(savedFiles[index]);
      file.title.value = savedNames[index];
      if (index == 0) {
        currentFile.value = file;
      }
      return file;
    });
  }
}
