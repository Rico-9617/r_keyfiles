import 'package:flutter/cupertino.dart';
import 'package:kdbx_lib/kdbx.dart';
import 'package:r_backup_tool/model/kdbx_file_wrapper.dart';
import 'package:r_backup_tool/repo/key_store_repo.dart';

class KeyEntryDetailController {
  final userNameEditController = TextEditingController();
  final urlEditController = TextEditingController();
  final noteEditController = TextEditingController();
  final pswEditController = TextEditingController();
  ProtectedValue? curPsw;

  KeyEntryDetailController(KdbxEntryWrapper entry) {
    userNameEditController.text =
        entry.entry.getString(KdbxKey('UserName'))?.getText() ?? '';
    userNameEditController.addListener(() {
      if (userNameEditController.text !=
          entry.entry.getString(KdbxKey('UserName'))?.getText()) {
        entry.modified.value = true;
      }
    });
    urlEditController.text =
        entry.entry.getString(KdbxKey('URL'))?.getText() ?? '';
    urlEditController.addListener(() {
      if (urlEditController.text !=
          entry.entry.getString(KdbxKey('URL'))?.getText()) {
        entry.modified.value = true;
      }
    });
    noteEditController.text =
        entry.entry.getString(KdbxKey('Notes'))?.getText() ?? '';
    noteEditController.addListener(() {
      if (noteEditController.text !=
          entry.entry.getString(KdbxKey('Notes'))?.getText()) {
        entry.modified.value = true;
      }
    });
    final originPsw = entry.entry.getString(KdbxKey('Password'));
    curPsw = originPsw as ProtectedValue?;
    pswEditController.text =
        originPsw?.getText().replaceAll(RegExp(r'.'), '*') ?? '';
  }

  dispose() {
    curPsw = null;
    userNameEditController.dispose();
    urlEditController.dispose();
    noteEditController.dispose();
    pswEditController.dispose();
  }

  switchPswDisplay(bool encrypt) {
    pswEditController.text = (encrypt
            ? curPsw?.getText().replaceAll(RegExp(r'.'), '*')
            : curPsw?.getText()) ??
        '';
  }

  Future<String?> saveChanges(
      KdbxFileWrapper keyFile, KdbxEntryWrapper entry) async {
    if (keyFile.kdbxFile == null) return '保存失败，文件未解锁';
    final originTitle = entry.entry.getString(KdbxKey('Title'));
    final originNotes = entry.entry.getString(KdbxKey('Notes'));
    final originURL = entry.entry.getString(KdbxKey('URL'));
    final originUserName = entry.entry.getString(KdbxKey('UserName'));
    final originPassword = entry.entry.getString(KdbxKey('Password'));
    entry.entry.setString(KdbxKey('Title'), entry.title.value);
    entry.entry
        .setString(KdbxKey('Notes'), PlainValue(noteEditController.text));
    entry.entry.setString(KdbxKey('URL'), PlainValue(urlEditController.text));
    entry.entry.setString(
        KdbxKey('UserName'), PlainValue(userNameEditController.text));
    entry.entry.setString(KdbxKey('Password'), curPsw);
    final saveResult = await KeyStoreRepo.instance.saveKeyStore(keyFile);
    if (saveResult != null) {
      entry.entry.setString(KdbxKey('Title'), originTitle);
      entry.entry.setString(KdbxKey('Notes'), originNotes);
      entry.entry.setString(KdbxKey('URL'), originURL);
      entry.entry.setString(KdbxKey('UserName'), originUserName);
      entry.entry.setString(KdbxKey('Password'), originPassword);
      return saveResult;
    }
    entry.modified.value = false;
    return null;
  }

  recover(KdbxEntryWrapper entry) {
    entry.title.value = entry.entry.getString(KdbxKey('Title'));
    noteEditController.text =
        entry.entry.getString(KdbxKey('Notes'))?.getText() ?? '';
    urlEditController.text =
        entry.entry.getString(KdbxKey('URL'))?.getText() ?? '';
    userNameEditController.text =
        entry.entry.getString(KdbxKey('UserName'))?.getText() ?? '';
    curPsw = entry.entry.getString(KdbxKey('Password')) as ProtectedValue?;
    pswEditController.text = curPsw?.getText().replaceAll(r'.', '*') ?? '';
    entry.modified.value = false;
  }

  modifyPsw(String psw, KdbxEntryWrapper entry) {
    curPsw = ProtectedValue.fromString(psw);
    if (curPsw != entry.entry.getString(KdbxKey('Password'))) {
      entry.modified.value = true;
    }
  }

  String? modifyEntryName(String name, KdbxEntryWrapper entry) {
    if (name.isEmpty) return '名称不能为空';
    entry.title.value = PlainValue(name);
    entry.modified.value = true;
    return null;
  }

  Future<String?> deleteEntry(
      KdbxFileWrapper keyFile, KdbxEntryWrapper entry) async {
    if (keyFile.kdbxFile == null) return '删除失败，文件未解锁';
    if (!keyFile.kdbxFile!.body.rootGroup.entries.remove(entry.entry)) {
      return '删除失败';
    }

    final saveResult = await KeyStoreRepo.instance.saveKeyStore(keyFile);
    if (saveResult != null) return saveResult;

    keyFile.entries.removeItem(entry);
    return null;
  }
}
