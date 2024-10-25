import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encryptKey;
import 'package:flutter/foundation.dart' as f;

class EncryptTool {
  EncryptTool._();

  static encryptKey.Encrypter _createEncryptor(String secretKey) =>
      encryptKey.Encrypter(encryptKey.AES(
          encryptKey.Key.fromUtf8(
              secretKey.length < 16 ? secretKey.padRight(16, '0') : secretKey),
          mode: encryptKey.AESMode.ecb,
          padding: 'PKCS7'));

  static String encrypt(String data, String secretKey) {
    try {
      return base64Encode(_createEncryptor(secretKey)
          .encrypt(data, iv: encryptKey.IV.fromLength(16))
          .bytes);
    } catch (e) {
      if (f.kDebugMode) print('encError: $e');
      return "";
    }
  }

  static String decrypt(String base64Data, String secretKey) {
    try {
      return _createEncryptor(secretKey).decrypt(
          encryptKey.Encrypted(base64Decode(base64Data)),
          iv: encryptKey.IV.fromLength(16));
    } catch (e) {
      if (f.kDebugMode) print('encError: $e');
      return "";
    }
  }

  static String md5String(String input) =>
      md5.convert(utf8.encode(input)).toString();
}
