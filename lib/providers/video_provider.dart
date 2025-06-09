import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:hand_speak/services/video_service.dart';
import 'dart:io';

// Video recording state
class VideoRecordingState {
  final bool isRecording;
  final bool isInitialized;
  final String? videoUrl;
  final String? error;

  VideoRecordingState({
    this.isRecording = false,
    this.isInitialized = true, // Default to true for simplicity
    this.videoUrl,
    this.error,
  });

  VideoRecordingState copyWith({
    bool? isRecording,
    bool? isInitialized,
    String? videoUrl,
    String? error,
  }) {
    return VideoRecordingState(
      isRecording: isRecording ?? this.isRecording,
      isInitialized: isInitialized ?? this.isInitialized,
      videoUrl: videoUrl ?? this.videoUrl,
      error: error,
    );
  }
}

// Video recording state notifier
class VideoRecordingNotifier extends StateNotifier<VideoRecordingState> {
  VideoRecordingNotifier() : super(VideoRecordingState());
  
  final VideoService _videoService = VideoService();

  Future<void> initCamera() async {
    try {
      state = state.copyWith(error: null);
      debugPrint('📹 Kamera başlatılıyor...');
      
      await _videoService.initCamera();
      state = state.copyWith(isInitialized: true);
      debugPrint('✅ Kamera hazır');
    } catch (e) {
      debugPrint('❌ Kamera başlatma hatası: $e');
      state = state.copyWith(error: e.toString(), isInitialized: false);
    }
  }

  Future<void> resetCamera() async {
    try {
      debugPrint('🔄 Kamera sıfırlanıyor...');
      _videoService.dispose();
      await Future.delayed(const Duration(seconds: 1));
      await initCamera();
    } catch (e) {
      debugPrint('❌ Kamera sıfırlama hatası: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> startRecording() async {
    try {
      state = state.copyWith(isRecording: true, error: null);
      debugPrint('🎬 Video kaydı başlatılıyor...');
      
      // Actually start recording using video service
      await _videoService.startRecording();
      debugPrint('✅ Video kayıt başarıyla başlatıldı');
    } catch (e) {
      debugPrint('❌ Video kayıt başlatma hatası: $e');
      state = state.copyWith(error: e.toString(), isRecording: false);
      
      // If camera hangs, try to reset it
      if (e.toString().contains('zaman aşımı') || e.toString().contains('timeout')) {
        debugPrint('🔄 Kamera dondu, sıfırlanıyor...');
        await resetCamera();
      }
    }
  }Future<void> stopRecording() async {
    try {
      state = state.copyWith(isRecording: false);
      debugPrint('Video kaydı durduruluyor ve yükleniyor...');
      
      // Stop recording and upload in one operation to prevent file issues
      final downloadUrl = await _videoService.stopRecordingAndUpload();
      debugPrint('Video başarıyla kaydedildi ve yüklendi: $downloadUrl');
      
      state = state.copyWith(videoUrl: downloadUrl);
    } catch (e) {
      debugPrint('Video kayıt ve yükleme hatası: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> processPickedVideo(String videoPath) async {
    try {
      debugPrint('Seçilen video işleniyor: $videoPath');
      state = state.copyWith(videoUrl: videoPath);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final videoRecordingStateProvider = StateNotifierProvider<VideoRecordingNotifier, VideoRecordingState>((ref) {
  return VideoRecordingNotifier();
});
