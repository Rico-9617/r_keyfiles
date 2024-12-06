import 'dart:io';

import 'package:r_backup_tool/foundation/list_value_notifier.dart';
import 'package:r_backup_tool/main.dart';
import 'package:r_backup_tool/utils/native_tool.dart';

class AndroidFilePickerController {
  final directories = ListValueNotifier<Directory>([]);
  final files = ListValueNotifier<FileSystemEntity>([]);

  Future init() async {
    gotoFolder(Directory(await getExternalDirectory()));
  }

  Future listFiles(Directory folder) async {
    List<FileSystemEntity> subFiles = await folder.list().toList();
    subFiles.sort((a, b) {
      bool isADirectory = FileSystemEntity.isDirectorySync(a.path);
      bool isBDirectory = FileSystemEntity.isDirectorySync(b.path);
      if (isADirectory && !isBDirectory) {
        return -1;
      } else if (!isADirectory && isBDirectory) {
        return 1;
      } else {
        return a.path.toLowerCase().compareTo(b.path.toLowerCase());
      }
    });
    files.replaceAllItems(subFiles);
  }

  Future gotoFolder(Directory folder) async {
    directories.addItem(folder);
    await listFiles(folder);
  }

  Future goBack(int index) async {
    logger.d('filedialog goback $index ${directories.size}');
    if (index < 0 || directories.size == 1) return;
    directories.removeRangeItems(index + 1, directories.size);
    logger.d('filedialog goback $index ${directories.size}');
    await listFiles(directories.value[index]);
  }
}
