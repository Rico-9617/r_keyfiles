import 'dart:convert';

import 'package:uuid/uuid.dart';

main() {
  final result = base64Encode(Uuid().v7().codeUnits).codeUnits;
  print('testfile ${''.split('test')}');
}
