import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encryptKey;
import 'package:r_backup_tool/main.dart';

class EncryptTool {
  EncryptTool._();

  static encryptKey.Encrypter _createEncryptor(String secretKey) =>
      encryptKey.Encrypter(encryptKey.AES(
          encryptKey.Key.fromUtf8(
              secretKey.length < 16 ? secretKey.padRight(16, '0') : secretKey),
          mode: encryptKey.AESMode.ecb,
          padding: 'PKCS7'));

  static String? encrypt(String data, String secretKey) {
    try {
      return base64Encode(_createEncryptor(secretKey)
          .encrypt(data, iv: encryptKey.IV.fromLength(16))
          .bytes);
    } catch (e) {
      logger.e('encError: $e');
      return null;
    }
  }

  static String? decrypt(String data, String secretKey) {
    try {
      return _createEncryptor(secretKey).decrypt(
          encryptKey.Encrypted(base64Decode(data)),
          iv: encryptKey.IV.fromLength(16));
    } catch (e) {
      logger.e('encError: $e');
      return null;
    }
  }

  static String md5String(String input) =>
      md5.convert(utf8.encode(input)).toString();
}
