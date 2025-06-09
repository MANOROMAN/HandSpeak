import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:hand_speak/core/services/logging_service.dart';

class MLService {
  final PoseDetector _poseDetector;
  
  MLService() : _poseDetector = PoseDetector(
    options: PoseDetectorOptions(
      mode: PoseDetectionMode.stream,
      model: PoseDetectionModel.accurate,
    ),
  );

  Future<List<Pose>> detectPose(InputImage inputImage) async {
    try {
      return await _poseDetector.processImage(inputImage);
    } catch (e) {
      LoggingService.error('Pose detection failed', e);
      return [];
    }
  }

  Future<String> interpretHandGesture(List<Pose> poses) async {
    if (poses.isEmpty) return 'No gesture detected';

    try {
      final pose = poses.first;
      // El pozisyonlarını analiz et
      final leftHand = _getHandPosition(pose, true);
      final rightHand = _getHandPosition(pose, false);

      // Hareket tanıma algoritması burada geliştirilecek
      return _recognizeGesture(leftHand, rightHand);
    } catch (e) {
      LoggingService.error('Gesture interpretation failed', e);
      return 'Error interpreting gesture';
    }
  }

  Map<String, PoseLandmark> _getHandPosition(Pose pose, bool isLeft) {
    final handLandmarks = <String, PoseLandmark>{};
    
    try {
      if (isLeft) {
        handLandmarks['wrist'] = pose.landmarks[PoseLandmarkType.leftWrist]!;
        handLandmarks['thumb'] = pose.landmarks[PoseLandmarkType.leftThumb]!;
        handLandmarks['index'] = pose.landmarks[PoseLandmarkType.leftPinky]!;
        // Diğer parmak pozisyonları eklenecek
      } else {
        handLandmarks['wrist'] = pose.landmarks[PoseLandmarkType.rightWrist]!;
        handLandmarks['thumb'] = pose.landmarks[PoseLandmarkType.rightThumb]!;
        handLandmarks['index'] = pose.landmarks[PoseLandmarkType.rightPinky]!;
        // Diğer parmak pozisyonları eklenecek
      }
      return handLandmarks;
    } catch (e) {
      LoggingService.error('Error getting hand position', e);
      return {};
    }
  }

  String _recognizeGesture(
    Map<String, PoseLandmark> leftHand,
    Map<String, PoseLandmark> rightHand,
  ) {
    // Temel hareket tanıma mantığı
    // Bu kısım daha sonra geliştirilecek ve makine öğrenimi modeli entegre edilecek
    if (leftHand.isEmpty && rightHand.isEmpty) {
      return 'No hands detected';
    }

    // Örnek basit hareket tanıma
    if (leftHand.isNotEmpty) {
      final wrist = leftHand['wrist']!;
      final thumb = leftHand['thumb']!;
      
      // Başparmak yukarıda ise
      if (thumb.y < wrist.y) {
        return 'Thumbs up';
      }
    }

    return 'Unknown gesture';
  }

  void dispose() {
    _poseDetector.close();
  }
}
