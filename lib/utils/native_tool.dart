import 'package:flutter/services.dart';

const nativeChannel = MethodChannel('rbackup');

requestStoragePermission() {
  return nativeChannel.invokeMethod('requestStoragePermission');
}
