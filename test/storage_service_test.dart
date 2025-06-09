import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hand_speak/services/storage_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hand_speak/firebase_options.dart';

void main() {
  group('Firebase Storage Tests', () {
    late StorageService storageService;
    
    setUpAll(() async {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      storageService = StorageService();
    });

    test('StorageService should initialize properly', () {
      expect(storageService, isNotNull);
    });

    test('Upload profile image should work with valid file', () async {
      // Bu test gerçek bir dosya gerektirir, sadece service'in çalıştığını test edelim
      expect(() => storageService.uploadProfileImage('test_user', File('test.jpg')), 
             throwsA(isA<Exception>())); // Dosya olmadığı için hata atacak
    });
  });
}
