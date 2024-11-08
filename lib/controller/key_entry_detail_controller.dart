import 'package:flutter/cupertino.dart';
import 'package:kdbx_lib/kdbx.dart';
import 'package:r_backup_tool/foundation/list_value_notifier.dart';
import 'package:r_backup_tool/main.dart';
import 'package:r_backup_tool/model/kdbx_file_wrapper.dart';
import 'package:r_backup_tool/repo/key_store_repo.dart';

class KeyEntryDetailController {
  final userNameEditController = TextEditingController();
  final urlEditController = TextEditingController();
  final noteEditController = TextEditingController();
  final pswEditController = TextEditingController();
  final tagsEditController = TextEditingController();
  final binaryData = ListValueNotifier<String>([]);
  ProtectedValue? curPsw;

  KeyEntryDetailController(KdbxEntryWrapper entry) {
    setDisplayUserName(entry);
    userNameEditController.addListener(() {
      if (userNameEditController.text !=
          entry.entry.getString(KdbxKey('UserName'))?.getText()) {
        entry.modified.value = true;
      }
    });
    setDisplayURL(entry);
    urlEditController.addListener(() {
      if (urlEditController.text !=
          entry.entry.getString(KdbxKey('URL'))?.getText()) {
        entry.modified.value = true;
      }
    });
    setDisplayNotes(entry);
    noteEditController.addListener(() {
      if (noteEditController.text !=
          entry.entry.getString(KdbxKey('Notes'))?.getText()) {
        entry.modified.value = true;
      }
    });
    final originPsw = entry.entry.getString(KdbxKey('Password'));
    curPsw = originPsw as ProtectedValue?;
    setDisplayPsw();

    setDisplayTags(entry);
    tagsEditController.addListener(() {
      if (tagsEditController.text != entry.entry.tags.get()) {
        entry.modified.value = true;
      }
    });

    binaryData.addAllItems(entry.entry.binaryEntries.map((e) => e.key.key));
  }

  void setDisplayTags(KdbxEntryWrapper entry) {
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

  Future<String?> saveChanges(
      KdbxFileWrapper keyFile, KdbxEntryWrapper entry) async {
    if (keyFile.kdbxFile == null) return '保存失败，文件未解锁';
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
    if (entry.newEntry) {
      entry.parent?.group.addEntry(entry.entry);
    }
    final saveResult = await KeyStoreRepo.instance.saveKeyStore(keyFile);
    if (saveResult != null) {
      entry.entry.setString(KdbxKey('Title'), originTitle);
      entry.entry.setString(KdbxKey('Notes'), originNotes);
      entry.entry.setString(KdbxKey('URL'), originURL);
      entry.entry.setString(KdbxKey('UserName'), originUserName);
      entry.entry.setString(KdbxKey('Password'), originPassword);
      entry.entry.tags.set(originTags);
      return saveResult;
    }
    entry.modified.value = false;
    entry.newEntry = false;
    return null;
  }

  recover(KdbxEntryWrapper entry) {
    entry.title.value = entry.entry.getString(KdbxKey('Title'));
    setDisplayNotes(entry);
    setDisplayURL(entry);
    setDisplayUserName(entry);
    setDisplayTags(entry);
    curPsw = entry.entry.getString(KdbxKey('Password')) as ProtectedValue?;
    setDisplayPsw();
    entry.modified.value = false;
  }

  void setDisplayNotes(KdbxEntryWrapper entry) {
    noteEditController.text =
        entry.entry.getString(KdbxKey('Notes'))?.getText() ?? '';
  }

  void setDisplayURL(KdbxEntryWrapper entry) {
    urlEditController.text =
        entry.entry.getString(KdbxKey('URL'))?.getText() ?? '';
  }

  void setDisplayUserName(KdbxEntryWrapper entry) {
    userNameEditController.text =
        entry.entry.getString(KdbxKey('UserName'))?.getText() ?? '';
  }

  modifyPsw(String psw, KdbxEntryWrapper entry) {
    curPsw = ProtectedValue.fromString(psw);
    if (curPsw != entry.entry.getString(KdbxKey('Password'))) {
      entry.modified.value = true;
      setDisplayPsw();
    }
  }

  void setDisplayPsw() {
    pswEditController.text = encryptPsw();
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
}
