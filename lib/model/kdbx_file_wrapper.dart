import 'package:flutter/widgets.dart';
import 'package:kdbx_lib/kdbx.dart';
import 'package:r_backup_tool/foundation/list_value_notifier.dart';
import 'package:r_backup_tool/repo/key_store_repo.dart';

class KdbxFileWrapper {
  final title = ValueNotifier('');
  String path = '';
  String id = '';
  final externalStore = ValueNotifier(false);
  KdbxFile? kdbxFile;
  final encrypted = ValueNotifier(true);
  KdbxGroupWrapper? rootGroup;
  final groups = ListValueNotifier(<KdbxGroupWrapper>[]);

  KdbxFileWrapper(this.path, {bool externalStore = false}) {
    this.externalStore.value = externalStore;
  }
}

class KdbxGroupWrapper {
  final title = ValueNotifier<String>('');
  KdbxGroupWrapper? parent;
  final KdbxGroup group;
  final groups = ListValueNotifier(<KdbxGroupWrapper>[]);
  final bool rootGroup;
  final bool recycleBin;

  final entries = ListValueNotifier(<KdbxEntryWrapper>[]);

  KdbxGroupWrapper(
      {required this.group,
      this.parent,
      this.rootGroup = false,
      this.recycleBin = false}) {
    title.value = group.name.get() ?? '';
    groups.value = group.groups
        .map((e) => KdbxGroupWrapper(
            group: e,
            parent: this,
            recycleBin: KeyStoreRepo.instance.isRecycleBin(group)))
        .toList();
    entries.value = group.entries
        .map((e) => KdbxEntryWrapper(entry: e, parent: this))
        .toList();
  }
}

class KdbxEntryWrapper {
  final title = ValueNotifier<StringValue?>(null);
  final KdbxEntry entry;
  KdbxGroupWrapper? parent;
  final modified = ValueNotifier(false);
  bool newEntry;

  KdbxEntryWrapper({required this.entry, this.parent, this.newEntry = false}) {
    title.value = entry.getString(KdbxKey('Title'));
  }
}
