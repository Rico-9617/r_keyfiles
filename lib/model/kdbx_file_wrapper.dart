import 'package:flutter/widgets.dart';
import 'package:kdbx_lib/kdbx.dart';
import 'package:r_backup_tool/foundation/list_value_notifier.dart';
import 'package:r_backup_tool/main.dart';

class KdbxFileWrapper {
  final title = ValueNotifier('');
  String path = '';
  String id = '';
  final externalStore = ValueNotifier(false);
  KdbxFile? kdbxFile;
  final encrypted = ValueNotifier(true);
  KdbxGroupWrapper? rootGroup;
  final groups = ListValueNotifier(<KdbxGroupWrapper>[]);
  final entries = ListValueNotifier(<KdbxEntryWrapper>[]);

  KdbxFileWrapper(this.path, {bool externalStore = false}) {
    this.externalStore.value = externalStore;
  }
}

class KdbxGroupWrapper {
  final title = ValueNotifier<String>('');
  final KdbxGroup group;
  final groups = ListValueNotifier(<KdbxGroupWrapper>[]);
  final bool removable;
  final modified = ValueNotifier(false);

  final entries = ListValueNotifier(<KdbxEntryWrapper>[]);

  KdbxGroupWrapper({required this.group, this.removable = true}) {
    logger.d('KdbxGroupWrapper ${group.name.get()}');
    title.value = group.name.get() ?? '';
    groups.value = group.groups.map((e) => KdbxGroupWrapper(group: e)).toList();
    entries.value =
        group.entries.map((e) => KdbxEntryWrapper(entry: e)).toList();
  }
}

class KdbxEntryWrapper {
  final title = ValueNotifier<StringValue?>(null);
  final KdbxEntry entry;
  final modified = ValueNotifier(false);

  KdbxEntryWrapper({required this.entry}) {
    title.value = entry.getString(KdbxKey('Title'));
  }
}
