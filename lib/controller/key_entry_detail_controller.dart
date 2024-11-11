import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:kdbx_lib/kdbx.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:r_backup_tool/foundation/list_value_notifier.dart';
import 'package:r_backup_tool/main.dart';
import 'package:r_backup_tool/model/kdbx_file_wrapper.dart';
import 'package:r_backup_tool/repo/key_store_repo.dart';

class KeyEntryDetailController {
  final KdbxFileWrapper keyFile;
  final KdbxEntryWrapper entry;
  final userNameEditController = TextEditingController();
  final urlEditController = TextEditingController();
  final noteEditController = TextEditingController();
  final pswEditController = TextEditingController();
  final tagsEditController = TextEditingController();
  final binaryData = ListValueNotifier<String>([]);
  final newBinaries = <String, String>{};
  final deletedBinaries = <String>[];
  ProtectedValue? curPsw;

  KeyEntryDetailController({required this.keyFile, required this.entry}) {
    setDisplayUserName();
    userNameEditController.addListener(() {
      if (userNameEditController.text !=
          entry.entry.getString(KdbxKey('UserName'))?.getText()) {
        entry.modified.value = true;
      }
    });
    setDisplayURL();
    urlEditController.addListener(() {
      if (urlEditController.text !=
          entry.entry.getString(KdbxKey('URL'))?.getText()) {
        entry.modified.value = true;
      }
    });
    setDisplayNotes();
    noteEditController.addListener(() {
      if (noteEditController.text !=
          entry.entry.getString(KdbxKey('Notes'))?.getText()) {
        entry.modified.value = true;
      }
    });
    final originPsw = entry.entry.getString(KdbxKey('Password'));
    curPsw = originPsw as ProtectedValue?;
    setDisplayPsw();

    setDisplayTags();
    tagsEditController.addListener(() {
      if (tagsEditController.text != entry.entry.tags.get()) {
        entry.modified.value = true;
      }
    });

    binaryData.addAllItems(entry.entry.binaryEntries.map((e) => e.key.key));
  }

  void setDisplayTags() {
    tagsEditController.text = entry.entry.tags.get() ?? '';
  }

  dispose() {
    curPsw = null;
    userNameEditController.dispose();
    urlEditController.dispose();
    noteEditController.dispose();
    pswEditController.dispose();
  }

  switchPswDisplay(bool encrypt) {
    pswEditController.text = (encrypt ? encryptPsw() : curPsw?.getText()) ?? '';
  }

  String encryptPsw() => curPsw == null ? '' : '******';

  Future<String?> saveChanges() async {
    if (keyFile.kdbxFile == null) return '保存失败，文件未解锁';
    String? saveResult = null;
    final originTitle = entry.entry.getString(KdbxKey('Title'));
    final originNotes = entry.entry.getString(KdbxKey('Notes'));
    final originURL = entry.entry.getString(KdbxKey('URL'));
    final originUserName = entry.entry.getString(KdbxKey('UserName'));
    final originPassword = entry.entry.getString(KdbxKey('Password'));
    final originTags = entry.entry.tags.get();
    entry.entry.setString(KdbxKey('Title'), entry.title.value);
    entry.entry
        .setString(KdbxKey('Notes'), PlainValue(noteEditController.text));
    entry.entry.setString(KdbxKey('URL'), PlainValue(urlEditController.text));
    entry.entry.setString(
        KdbxKey('UserName'), PlainValue(userNameEditController.text));
    entry.entry.setString(KdbxKey('Password'), curPsw);
    entry.entry.tags.set(tagsEditController.text);
    final addedKeys = <String>[];
    try {
      newBinaries.forEach((k, v) async {
        final file = File(v);
        if (file.existsSync()) {
          entry.entry.createBinary(
              isProtected: true, name: k, bytes: file.readAsBytesSync());
          addedKeys.add(k);
        }
      });
    } catch (e) {
      logger.e(e);
      saveResult = '保存失败';
    }
    final deleteData = <String, KdbxBinary>{};
    for (final delKey in deletedBinaries) {
      deleteData[delKey] = entry.entry.getBinary(KdbxKey(delKey))!;
    }
    if (entry.newEntry) {
      entry.parent?.group.addEntry(entry.entry);
    }
    saveResult = await KeyStoreRepo.instance.saveKeyStore(keyFile);
    if (saveResult != null) {
      entry.entry.setString(KdbxKey('Title'), originTitle);
      entry.entry.setString(KdbxKey('Notes'), originNotes);
      entry.entry.setString(KdbxKey('URL'), originURL);
      entry.entry.setString(KdbxKey('UserName'), originUserName);
      entry.entry.setString(KdbxKey('Password'), originPassword);
      entry.entry.tags.set(originTags);
      for (var k in addedKeys) {
        entry.entry.removeBinary(KdbxKey(k));
      }
      for (var k in deleteData.keys) {
        final data = deleteData[k]!;
        entry.entry.createBinary(
            isProtected: data.isProtected, name: k, bytes: data.value);
      }
      return saveResult;
    }
    entry.modified.value = false;
    entry.newEntry = false;
    return null;
  }

  recover() {
    entry.title.value = entry.entry.getString(KdbxKey('Title'));
    // setDisplayNotes(entry);
    // setDisplayURL(entry);
    // setDisplayUserName(entry);
    // setDisplayTags(entry);
    // curPsw = entry.entry.getString(KdbxKey('Password')) as ProtectedValue?;
    // setDisplayPsw();
    entry.modified.value = false;
  }

  void setDisplayNotes() {
    noteEditController.text =
        entry.entry.getString(KdbxKey('Notes'))?.getText() ?? '';
  }

  void setDisplayURL() {
    urlEditController.text =
        entry.entry.getString(KdbxKey('URL'))?.getText() ?? '';
  }

  void setDisplayUserName() {
    userNameEditController.text =
        entry.entry.getString(KdbxKey('UserName'))?.getText() ?? '';
  }

  modifyPsw(
    String psw,
  ) {
    curPsw = ProtectedValue.fromString(psw);
    if (curPsw != entry.entry.getString(KdbxKey('Password'))) {
      entry.modified.value = true;
      setDisplayPsw();
    }
  }

  void setDisplayPsw() {
    pswEditController.text = encryptPsw();
  }

  String? modifyEntryName(
    String name,
  ) {
    if (name.isEmpty) return '名称不能为空';
    entry.title.value = PlainValue(name);
    entry.modified.value = true;
    return null;
  }

  Future<String?> deleteEntry() async {
    if (keyFile.kdbxFile == null) return '删除失败，文件未解锁';
    try {
      if (KeyStoreRepo.instance.isUnderRecycleBin(entry.parent!)) {
        //in recycle bin
        entry.entry.file.deletePermanently(entry.entry);
      } else {
        entry.entry.file.deleteEntry(entry.entry);
      }
    } catch (e) {
      logger.e(e);
      return '删除失败';
    }
    entry.parent!.entries.removeItem(entry);

    if (!entry.newEntry) {
      final saveResult = await KeyStoreRepo.instance.saveKeyStore(keyFile);
      if (saveResult != null) return saveResult;
    }
    return null;
  }

  void deleteBinary(String key) {
    binaryData.removeItem(key);
    deletedBinaries.add(key);
    entry.modified.value = true;
  }

  void addBinary(String path) {
    final fileName = path.split('/').last;
    String name = fileName;
    int count = 1;
    while (binaryData.value.contains(name)) {
      name = '${fileName}_${count++}';
    }
    binaryData.addItem(name);
    newBinaries[name] = path;
    entry.modified.value = true;
  }

  Future<String?> saveFile(String key) async {
    final data = entry.entry.getBinary(KdbxKey(key))?.value;
    if (data == null) return '导出失败，数据错误';
    try {
      final folder = await getDownloadsDirectory();
      int count = 1;
      final files = folder!.listSync().map((e) => e.path.split('/').last);
      String name = key;
      while (files.contains(name)) {
        final arr = key.split(('.'));
        name = arr.length > 1
            ? '${arr[0]}_${count++}.${arr[1]}'
            : '${arr[0]}_${count++}';
      }
      final file = File(p.join(folder.path, name));
      file.createSync();
      file.writeAsBytesSync(data, flush: true);
      return '文件已保存到${file.path}';
    } catch (e) {
      logger.e(e);
    }
    return '导出失败';
  }
}
