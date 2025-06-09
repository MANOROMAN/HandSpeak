import 'dart:convert';
import 'package:crypto/crypto.dart';

class SecurityUtils {
  // String'i hash'ler (SHA-256)
  static String hashString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Güvenli bir şekilde iki string karşılaştırır (zamanlama saldırılarına karşı koruma)
  static bool secureCompare(String a, String b) {
    if (a.length != b.length) {
      return false;
    }

    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }

    return result == 0;
  }
}
