import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:hand_speak/models/video_quality_settings.dart';
import 'package:hand_speak/core/services/storage_service.dart';
import 'package:hand_speak/services/video_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this import

// Video kalite ayarları provider
final videoQualityProvider = StateNotifierProvider<VideoQualityNotifier, VideoQualitySettings>((ref) {
  final storageService = StorageService();
  final videoService = ref.watch(videoServiceProvider);
  return VideoQualityNotifier(storageService, videoService);
});

// Video servisi provider referansı
final videoServiceProvider = Provider<VideoService>((ref) {
  return VideoService();
});

class VideoQualityNotifier extends StateNotifier<VideoQualitySettings> {
  final StorageService _storageService;
  final VideoService _videoService;
  static const String _storageKey = 'video_quality_settings';
  
  VideoQualityNotifier(this._storageService, this._videoService) 
    : super(const VideoQualitySettings()) {
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    try {
      // Önce yerel depolamadan yükle
      final localSettings = await _storageService.getJson(_storageKey);
      if (localSettings != null) {
        state = VideoQualitySettings.fromMap(localSettings);
        debugPrint('✅ Video kalite ayarları yerel depolamadan yüklendi: $state');
      }
      
      // Kullanıcı oturum açmışsa Firestore'dan da yükle (varsa)
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await user.getIdTokenResult();
        if (userData != null && userData.claims != null && 
            userData.claims!['videoSettings'] != null) {
          state = VideoQualitySettings.fromMap(userData.claims!['videoSettings']);
          debugPrint('✅ Video kalite ayarları Firebase\'den yüklendi: $state');
        }
      }
      
      // VideoService'i güncel ayarlarla yapılandır
      await _videoService.updateQualitySettings(state);
      
    } catch (e) {
      debugPrint('❌ Video kalite ayarları yüklenemedi: $e');
    }
  }
  
  Future<void> updateSettings({
    ResolutionPreset? resolution,
    int? frameRate,
    bool? enableAudio,
  }) async {
    // Yeni ayarları oluştur
    final newSettings = state.copyWith(
      resolution: resolution,
      frameRate: frameRate,
      enableAudio: enableAudio,
    );
    
    // Durumu güncelle
    state = newSettings;
    
    try {
      // Yerel depolamaya kaydet
      await _storageService.saveJson(_storageKey, newSettings.toMap());
      
      // VideoService'i güncelle
      await _videoService.updateQualitySettings(newSettings);
      
      // Kullanıcı oturum açmışsa Firestore'a da kaydet
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'preferences.videoSettings': newSettings.toMap(),
        });
        debugPrint('✅ Video kalite ayarları Firebase\'e kaydedildi: $newSettings');
      }
    } catch (e) {
      debugPrint('❌ Video kalite ayarları kaydedilemedi: $e');
      rethrow; // Hata durumunu üstte yakalayabilmek için
    }
  }
}
