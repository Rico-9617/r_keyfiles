import 'package:kdbx_lib/kdbx.dart';
import 'package:r_backup_tool/model/kdbx_file_wrapper.dart';

class KeyGroupDetailController {
  createGroup(
      String name, KdbxFileWrapper fileWrapper, KdbxGroupWrapper parent) {
    if (fileWrapper.kdbxFile == null) return '创建失败';
    fileWrapper.kdbxFile!.body.rootGroup.groups[0];
    KdbxGroup.create(
        ctx: fileWrapper.kdbxFile!.ctx, parent: parent.group, name: name);
  }

  createEntry(String name, KdbxFileWrapper fileWrapper) {
    if (fileWrapper.kdbxFile == null) return '创建失败';
    fileWrapper.kdbxFile!.body.rootGroup.groups[0];
    KdbxEntry.create(
        fileWrapper.kdbxFile!, fileWrapper.kdbxFile!.body.rootGroup);
  }
}
