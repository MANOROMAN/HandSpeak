import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:hand_speak/core/services/logging_service.dart';
import 'package:hand_speak/core/services/ml_service.dart';

class CameraService {
  CameraController? _controller;
  MLService? _mlService;
  bool _isProcessing = false;

  Future<void> initialize() async {
    try {
      final cameras = await availableCameras();
      final front = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.yuv420
            : ImageFormatGroup.bgra8888,
      );

      await _controller!.initialize();
      _mlService = MLService();

      // Her frame'i işle
      _controller!.startImageStream(_processImage);
    } catch (e) {
      LoggingService.error('Camera initialization failed', e);
      rethrow;
    }
  }

  Future<void> _processImage(CameraImage image) async {
    if (_isProcessing) return;

    _isProcessing = true;
    try {
      final inputImage = _convertCameraImage(image);
      if (inputImage != null) {
        final poses = await _mlService!.detectPose(inputImage);
        final gesture = await _mlService!.interpretHandGesture(poses);
        
        // Gesture detected olayını tetikle
        onGestureDetected?.call(gesture);
      }
    } catch (e) {
      LoggingService.error('Image processing failed', e);
    } finally {
      _isProcessing = false;
    }
  }

  InputImage? _convertCameraImage(CameraImage image) {
    try {
      final bytes = _concatenatePlanes(image.planes);
      final imageSize = Size(image.width.toDouble(), image.height.toDouble());

      final imageRotation = InputImageRotation.rotation0deg;
      final inputImageFormat = InputImageFormat.bgra8888;

      return InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: imageSize,
          rotation: imageRotation,
          format: inputImageFormat,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );
    } catch (e) {
      LoggingService.error('Converting camera image failed', e);
      return null;
    }
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final WriteBuffer buffer = WriteBuffer();
    for (final plane in planes) {
      buffer.putUint8List(plane.bytes);
    }
    return buffer.done().buffer.asUint8List();
  }

  void Function(String)? onGestureDetected;

  bool get isInitialized => _controller?.value.isInitialized ?? false;
  CameraController? get controller => _controller;

  void dispose() {
    _controller?.dispose();
    _mlService?.dispose();
  }
}
