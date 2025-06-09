import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hand_speak/core/utils/security_utils.dart';
import 'dart:math';

class EmailAuthService {
  static final EmailAuthService _instance = EmailAuthService._internal();
  factory EmailAuthService() => _instance;
  static EmailAuthService get instance => _instance;
  EmailAuthService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    // E-postaya doğrulama kodu gönderir
  Future<void> sendVerificationCode(String email) async {
    try {
      // E-posta formatını doğrula
      if (!_isValidEmail(email)) {
        throw Exception('Geçersiz e-posta adresi formatı.');
      }

      // 6 haneli rastgele bir kod oluştur
      final verificationCode = _generateVerificationCode();
      
      // Son kullanma tarihi (15 dakika sonra)
      final expiresAt = DateTime.now().add(const Duration(minutes: 15));
      
      // Kodu hashed olarak sakla
      final hashedCode = SecurityUtils.hashString(verificationCode);
      
      // Firestore'da kaydet
      await _firestore.collection('verification_codes').doc(email).set({
        'code': hashedCode,
        'expiresAt': expiresAt,
        'attempts': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // Burada e-posta gönderme işlemi gerçekleştir
      await _sendVerificationEmail(email, verificationCode);
      
      debugPrint('✅ Verification code sent to $email');
    } catch (e) {
      debugPrint('❌ Error sending verification code: $e');
      rethrow;
    }
  }

  // Doğrulama kodunu doğrular
  Future<bool> verifyCode(String email, String code) async {
    try {
      // Firestore'dan kod bilgilerini al
      final doc = await _firestore.collection('verification_codes').doc(email).get();
      
      if (!doc.exists) {
        throw Exception('Doğrulama kodu bulunamadı. Lütfen yeni bir kod talep edin.');
      }
      
      final data = doc.data()!;
      final hashedCode = data['code'] as String;
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();
      final attempts = data['attempts'] as int;
      
      // Deneme sayısını güncelle
      await _firestore.collection('verification_codes').doc(email).update({
        'attempts': attempts + 1,
      });
      
      // Maksimum deneme sayısı kontrolü (5 kez)
      if (attempts >= 5) {
        throw Exception('Maksimum deneme sayısı aşıldı. Lütfen yeni bir kod talep edin.');
      }
      
      // Son kullanma tarihi kontrolü
      if (DateTime.now().isAfter(expiresAt)) {
        throw Exception('Doğrulama kodu süresi dolmuş. Lütfen yeni bir kod talep edin.');
      }
      
      // Kod doğrulama
      final inputHashedCode = SecurityUtils.hashString(code);
      
      if (hashedCode != inputHashedCode) {
        throw Exception('Doğrulama kodu geçersiz. Lütfen tekrar deneyin.');
      }
      
      // Başarılı doğrulama - kodu sil
      await _firestore.collection('verification_codes').doc(email).delete();
      
      return true;
    } catch (e) {
      debugPrint('❌ Error verifying code: $e');
      rethrow;
    }
  }

  // 6 haneli rastgele doğrulama kodu oluşturur
  String _generateVerificationCode() {
    final random = Random.secure();
    return (100000 + random.nextInt(900000)).toString();
  }
  
  // Email gönderme işlemi (Firebase Cloud Functions ile entegre edilecek)
  Future<void> _sendVerificationEmail(String email, String code) async {
    // Bu fonksiyon Firebase Cloud Functions kullanarak gerçek e-posta göndermek için
    // kullanılacak. Şimdilik test e-postaları için basit bir işlev.
    
    await _firestore.collection('mail_queue').add({
      'to': email,
      'template': 'verification',
      'code': code,
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    debugPrint('✉️ Mail queued with verification code: $code to $email');
    // Not: Gerçek senaryoda kodu log'lamamalıyız!
  }

  // E-posta formatını doğrular
  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }
}
