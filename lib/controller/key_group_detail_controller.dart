import 'package:kdbx_lib/kdbx.dart';
import 'package:r_backup_tool/model/kdbx_file_wrapper.dart';
import 'package:r_backup_tool/repo/key_store_repo.dart';

class KeyGroupDetailController {
  Future<String?> createGroup(
      String name, KdbxGroupWrapper parent, KdbxFileWrapper fileWrapper) async {
    if (fileWrapper.kdbxFile == null) return '创建失败';
    final newGroup = KdbxGroup.create(
        ctx: fileWrapper.kdbxFile!.ctx, parent: parent.group, name: name);
    parent.group.addGroup(newGroup);
    final saveResult = await KeyStoreRepo.instance.saveKeyStore(fileWrapper);
    if (saveResult != null) {
      parent.group.groups.remove(newGroup);
      return saveResult;
    }
    parent.groups.addItem(KdbxGroupWrapper(group: newGroup));
    return null;
  }

  Future<String?> createEntry(
      String name, KdbxGroupWrapper group, KdbxFileWrapper fileWrapper) async {
    if (fileWrapper.kdbxFile == null) return '创建失败';
    final newEntry = KdbxEntry.create(
        fileWrapper.kdbxFile!, fileWrapper.kdbxFile!.body.rootGroup);
    // group.group.addEntry(newEntry);
    final saveResult = await KeyStoreRepo.instance.saveKeyStore(fileWrapper);
    if (saveResult != null) {
      group.group.entries.remove(newEntry);
      return saveResult;
    }
    group.entries.addItem(KdbxEntryWrapper(entry: newEntry));
    return null;
  }

  Future<String?> deleteGroup(
      KdbxGroupWrapper group, KdbxFileWrapper fileWrapper) async {
    if (group.parent == null) return '删除失败';
    if (!group.parent!.group.groups.remove(group.group)) return '删除失败';
    final saveResult = await KeyStoreRepo.instance.saveKeyStore(fileWrapper);
    if (saveResult != null) {
      return saveResult;
    }
    group.parent!.groups.removeItem(group);
    return null;
  }

  Future<String?> modifyGroupTitle(
    String title,
    KdbxGroupWrapper group,
    KdbxFileWrapper fileWrapper,
  ) async {
    if (fileWrapper.kdbxFile == null) return '修改失败';
    if (!group.group.name.set(title)) return '修改失败';
    final saveResult = await KeyStoreRepo.instance.saveKeyStore(fileWrapper);
    if (saveResult != null) return saveResult;
    if (group.rootGroup) {
      await KeyStoreRepo.instance.updateSavedFiles(fileWrapper, (data) {
        data[0] = title;
        return data;
      });
    }
    fileWrapper.title.value = title;
    return null;
  }
}
