import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  // Video kaydı başlatılınca event
  Future<void> logVideoRecordingStarted() async {
    try {
      await _analytics.logEvent(
        name: 'video_recording_started',
        parameters: {
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
    } catch (e) {
      debugPrint('Firebase Analytics error: $e');
    }
  }
  
  // Video kaydı tamamlanınca event
  Future<void> logVideoRecordingCompleted(int durationSeconds, bool wasUploaded) async {
    try {
      await _analytics.logEvent(
        name: 'video_recording_completed',
        parameters: {
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'duration_seconds': durationSeconds,
          'was_uploaded': wasUploaded,
        },
      );
    } catch (e) {
      debugPrint('Firebase Analytics error: $e');
    }
  }
  
  // Video yükleme başarılı olunca event
  Future<void> logVideoUploaded(String videoId, int fileSizeBytes) async {
    try {
      await _analytics.logEvent(
        name: 'video_uploaded',
        parameters: {
          'video_id': videoId,
          'file_size_bytes': fileSizeBytes,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
    } catch (e) {
      debugPrint('Firebase Analytics error: $e');
    }
  }
  
  // Video oynatma event
  Future<void> logVideoPlayed(String videoId) async {
    try {
      await _analytics.logEvent(
        name: 'video_played',
        parameters: {
          'video_id': videoId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
    } catch (e) {
      debugPrint('Firebase Analytics error: $e');
    }
  }
  
  // Model çevirisi tamamlandı event
  Future<void> logTranslationCompleted(String videoId, bool wasSuccessful, int processingTimeMs) async {
    try {
      await _analytics.logEvent(
        name: 'translation_completed',
        parameters: {
          'video_id': videoId,
          'was_successful': wasSuccessful,
          'processing_time_ms': processingTimeMs,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
    } catch (e) {
      debugPrint('Firebase Analytics error: $e');
    }
  }
}
