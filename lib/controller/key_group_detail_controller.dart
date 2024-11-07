import 'package:kdbx_lib/kdbx.dart';
import 'package:r_backup_tool/main.dart';
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

  Future<({KdbxEntryWrapper? entryWrapper, String? result})> createEntry(
      String name, KdbxGroupWrapper groupWrapper, KdbxFileWrapper fileWrapper) async {
    if (fileWrapper.kdbxFile == null) return (entryWrapper: null, result: '创建失败');
    final newEntry = KdbxEntry.create(fileWrapper.kdbxFile!, groupWrapper.group);
    // group.group.addEntry(newEntry);
    newEntry.setString(KdbxKey('Title'), PlainValue(name));
    // final saveResult = await KeyStoreRepo.instance.saveKeyStore(fileWrapper);
    // if (saveResult != null) {
    //   group.group.entries.remove(newEntry);
    //   return saveResult;
    // }
    final entryWrapper =
        KdbxEntryWrapper(entry: newEntry, parent: groupWrapper, newEntry: true);
    entryWrapper.modified.value = true;
    groupWrapper.entries.addItem(entryWrapper);
    return (entryWrapper: entryWrapper, result: null);
  }

  void recoverEntry(
      KdbxEntryWrapper entryWrapper, KdbxGroupWrapper groupWrapper, KdbxFileWrapper keyFile) {
    if (keyFile.kdbxFile == null) return;
    // keyFile.kdbxFile?.deleteEntry(entry.entry);
    groupWrapper.entries.removeItem(entryWrapper);
  }

  Future<String?> deleteGroup(
      KdbxGroupWrapper groupWrapper, KdbxFileWrapper fileWrapper) async {
    if (groupWrapper.parent == null || fileWrapper.kdbxFile == null) return '删除失败';
    try {
      if (KeyStoreRepo.instance.isUnderRecycleBin(groupWrapper.parent!)) {
        //in recycle bin
        fileWrapper.kdbxFile!.deletePermanently(groupWrapper.group);
      } else {
        fileWrapper.kdbxFile!.deleteGroup(groupWrapper.group);
      }
    } catch (e) {
      logger.e(e);
      return '删除失败';
    }
    final saveResult = await KeyStoreRepo.instance.saveKeyStore(fileWrapper);
    if (saveResult != null) {
      return saveResult;
    }
    groupWrapper.parent!.groups.removeItem(groupWrapper);
    return null;
  }

   String?  clearRecycleBin(KdbxGroupWrapper groupWrapper){
    try{
      for (var subGroupWrapper in groupWrapper.groups.value) {
        groupWrapper.group.file.deletePermanently(subGroupWrapper.group);
      }
      groupWrapper.groups.clearItems();
      for (var entryWrapper in groupWrapper.entries.value) {
        groupWrapper.group.file.deletePermanently(entryWrapper.entry);
      }
      groupWrapper.entries.clearItems();
      return null;
    }catch(e){
      logger.e(e);
    }
    return '清空失败';
  }

  Future<String?> modifyGroupTitle(
    String title,
    KdbxGroupWrapper groupWrapper,
    KdbxFileWrapper fileWrapper,
  ) async {
    if (fileWrapper.kdbxFile == null) return '修改失败';
    if (!groupWrapper.group.name.set(title)) return '修改失败';
    final saveResult = await KeyStoreRepo.instance.saveKeyStore(fileWrapper);
    if (saveResult != null) return saveResult;
    if (groupWrapper.rootGroup) {
      await KeyStoreRepo.instance.updateSavedFiles(fileWrapper, (data) {
        data[0] = title;
        return data;
      });
    }
    groupWrapper.title.value = title;
    return null;
  }
}
