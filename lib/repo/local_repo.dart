import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:r_backup_tool/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalRepo {
  LocalRepo._();

  static LocalRepo? _instance;

  static late SharedPreferencesAsync savor;

  static LocalRepo get instance {
    if (_instance == null) {
      _instance = LocalRepo._();
      savor = SharedPreferencesAsync();
    }
    return _instance!;
  }

  static Future<Directory> _getConfigFolder() async {
    final directory = Directory(
        p.join((await getApplicationDocumentsDirectory()).path, '.app_conf'));
    logger.d(directory);
    if (!await directory.exists()) {
      await directory.create();
    }
    return directory;
  }

  Future<File> getConfigFile({String name = '.def'}) async {
    final file = File(p.join((await _getConfigFolder()).path, name));
    if (!await file.exists()) {
      await file.create();
    }
    return file;
  }

  saveString(String key, String data) async {
    await savor.setString(key, data);
  }

  Future<String?> getString(String key) async {
    return await savor.getString(key);
  }

  saveStrings(String key, List<String> data) async {
    await savor.setStringList(key, data);
  }

  Future<List<String>?> getStrings(String key) async {
    return await savor.getStringList(key);
  }
}
