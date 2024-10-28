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
