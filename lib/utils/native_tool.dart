import 'package:flutter/services.dart';
import 'package:r_backup_tool/main.dart';

const nativeChannel = MethodChannel('rbackup');

Future<bool> requestStoragePermission() async {
  final result =
      await nativeChannel.invokeMethod('requestStoragePermission') as bool;
  hasExternalStoragePermission.value = result;
  return result;
}

Future<bool> checkStoragePermission() async {
  return await nativeChannel.invokeMethod('checkStoragePermission') as bool;
}

Future<String> getDownloadDirectory() async {
  return await nativeChannel.invokeMethod('getDownloadDirectory') as String;
}

Future<String> getDocumentDirectory() async {
  return await nativeChannel.invokeMethod('getDocumentDirectory') as String;
}
