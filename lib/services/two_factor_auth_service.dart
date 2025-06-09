import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TwoFactorAuthService {
  final FirebaseAuth _auth;
  static const int SECRET_LENGTH = 20;
  static const String ISSUER = 'HandSpeak';

  TwoFactorAuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  /// Rastgele bir gizli anahtar oluşturur
  String _generateSecret() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final random = Random.secure();
    return List.generate(SECRET_LENGTH, (index) => chars[random.nextInt(chars.length)]).join();
  }

  /// QR kodu için TOTP URI'sini oluşturur
  String _generateTotpUri(String secret, String email) {
    final uri = Uri(
      scheme: 'otpauth',
      host: 'totp',
      path: '/$ISSUER:$email',
      queryParameters: {
        'secret': secret,
        'issuer': ISSUER,
        'algorithm': 'SHA1',
        'digits': '6',
        'period': '30',
      },
    );
    return uri.toString();
  }

  /// 2FA kurulumunu başlatır
  Future<Map<String, String>> setupTwoFactor() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Kullanıcı oturum açmamış');
    }

    final secret = _generateSecret();
    final uri = _generateTotpUri(secret, user.email!);

    // TODO: Gizli anahtarı güvenli bir şekilde Firebase'de sakla
    
    return {
      'secret': secret,
      'uri': uri,
    };
  }

  /// Verilen TOTP kodunu doğrular
  Future<bool> verifyTotpCode(String code) async {
    if (code.length != 6) {
      throw Exception('Geçersiz kod uzunluğu');
    }

    // TODO: Firebase'den gizli anahtarı al ve TOTP kodunu doğrula
    // Şimdilik her zaman true dönüyoruz, gerçek implementasyonda düzeltilecek
    return true;
  }

  /// 2FA durumunu kontrol eder
  Future<bool> isTwoFactorEnabled() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Kullanıcı oturum açmamış');
    }

    // TODO: Firebase'den kullanıcının 2FA durumunu kontrol et
    return false;
  }
}
