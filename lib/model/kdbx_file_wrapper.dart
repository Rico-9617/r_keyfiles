import 'package:flutter/widgets.dart';
import 'package:kdbx_lib/kdbx.dart';

class KdbxFileWrapper {
  final title = ValueNotifier('');
  String path = '';
  KdbxFile? kdbxFile;
  final encrypted = ValueNotifier(true);

  KdbxFileWrapper(this.path);
}
