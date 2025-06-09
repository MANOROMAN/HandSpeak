import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart'; // kIsWeb için import ekledik

class VideoQualitySettings extends Equatable {
  final ResolutionPreset resolution;
  final int frameRate;
  final bool enableAudio;

  const VideoQualitySettings({
    this.resolution = ResolutionPreset.medium,
    this.frameRate = 30,
    this.enableAudio = true,
  });

  @override
  List<Object?> get props => [resolution, frameRate, enableAudio];

  VideoQualitySettings copyWith({
    ResolutionPreset? resolution,
    int? frameRate,
    bool? enableAudio,
  }) {
    return VideoQualitySettings(
      resolution: resolution ?? this.resolution,
      frameRate: frameRate ?? this.frameRate,
      enableAudio: enableAudio ?? this.enableAudio,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'resolution': resolution.name,
      'frameRate': frameRate,
      'enableAudio': enableAudio,
    };
  }

  factory VideoQualitySettings.fromMap(Map<String, dynamic> map) {
    return VideoQualitySettings(
      resolution: ResolutionPreset.values.firstWhere(
        (preset) => preset.name == map['resolution'],
        orElse: () => ResolutionPreset.medium,
      ),
      frameRate: map['frameRate'] ?? 30,
      enableAudio: map['enableAudio'] ?? true,
    );
  }

  @override
  String toString() {
    return 'VideoQualitySettings(resolution: $resolution, frameRate: $frameRate, enableAudio: $enableAudio)';
  }

  /// Kullanıcı arayüzünde gösterilecek kalite seçenekleri
  static List<Map<String, dynamic>> get qualityOptions {
    return [
      {'value': ResolutionPreset.low, 'label': 'Düşük'},
      {'value': ResolutionPreset.medium, 'label': 'Orta'},
      {'value': ResolutionPreset.high, 'label': 'Yüksek'},
      {'value': ResolutionPreset.veryHigh, 'label': 'Çok Yüksek'},
      if (!kIsWeb) {'value': ResolutionPreset.ultraHigh, 'label': 'Ultra Yüksek (4K)'},
      if (!kIsWeb) {'value': ResolutionPreset.max, 'label': 'Maksimum'},
    ];
  }

  /// Kaliteye göre önerilen frame rate
  static int getRecommendedFrameRate(ResolutionPreset resolution) {
    switch (resolution) {
      case ResolutionPreset.low:
        return 15;
      case ResolutionPreset.medium:
        return 24;
      case ResolutionPreset.high:
        return 30;
      case ResolutionPreset.veryHigh:
        return 30;
      case ResolutionPreset.ultraHigh:
        return 30;
      case ResolutionPreset.max:
        return 30;
      default:
        return 30;
    }
  }
}
