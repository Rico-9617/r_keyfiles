import 'package:flutter/widgets.dart';
import 'package:kdbx_lib/kdbx.dart';

class KdbxFileWrapper {
  final title = ValueNotifier('');
  String path = '';
  KdbxFile? kdbxFile;
  final encrypted = ValueNotifier(true);
  final entities = ValueNotifier(<KdbxEntryWrapper>[]);

  KdbxFileWrapper(this.path);
}

class KdbxEntryWrapper {
  final title = ValueNotifier<StringValue?>(null);
  final note = ValueNotifier<StringValue?>(null);
  final url = ValueNotifier<StringValue?>(null);
  final username = ValueNotifier<StringValue?>(null);
  final psw = ValueNotifier<StringValue?>(null);
  final KdbxEntry entry;

  KdbxEntryWrapper({required this.entry}) {
    for (final se in entry.stringEntries) {
      print(
          'restparse entry string: ${se.key.key}  = ${se.value?.getText()}  ');
      title.value = entry.getString(KdbxKey('Title'));
      note.value = entry.getString(KdbxKey('Notes'));
      url.value = entry.getString(KdbxKey('URL'));
      username.value = entry.getString(KdbxKey('UserName'));
      psw.value = entry.getString(KdbxKey('Password'));
    }
  }
}
