import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _currentCameraIndex = 0;
  bool _isInitialized = false;
  bool _isInitializing = false;
  
  // Getter methods
  bool get isInitialized => _isInitialized;
  CameraController? get controller => _controller;
  int get currentCameraIndex => _currentCameraIndex;
  List<CameraDescription> get cameras => _cameras;
  bool get hasFrontCamera => _cameras.any((camera) => camera.lensDirection == CameraLensDirection.front);
  bool get hasBackCamera => _cameras.any((camera) => camera.lensDirection == CameraLensDirection.back);
  bool get isFrontCamera => _cameras.isNotEmpty && _currentCameraIndex < _cameras.length && 
                           _cameras[_currentCameraIndex].lensDirection == CameraLensDirection.front;
  
  // Kamera başlatma
  Future<void> initCamera() async {
    if (_isInitializing) {
      debugPrint('⚠️ Kamera zaten başlatılıyor, bekleyin...');
      return;
    }
    
    if (_isInitialized && _controller != null && _controller!.value.isInitialized) {
      debugPrint('✅ Kamera zaten başlatılmış');
      return;
    }
    
    _isInitializing = true;
    
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        debugPrint('❌ Hiç kamera bulunamadı');
        return;
      }
      
      // Varsayılan olarak arka kamera ile başlat
      _currentCameraIndex = _cameras.indexWhere((camera) => 
        camera.lensDirection == CameraLensDirection.back);
      
      // Arka kamera yoksa ön kamerayı kullan
      if (_currentCameraIndex < 0) {
        _currentCameraIndex = _cameras.indexWhere((camera) => 
          camera.lensDirection == CameraLensDirection.front);
      }
      
      // Hiç kamera yoksa ilk kamerayı kullan
      if (_currentCameraIndex < 0 && _cameras.isNotEmpty) {
        _currentCameraIndex = 0;
      }
      
      await _initController();
      
      if (_isInitialized && _currentCameraIndex < _cameras.length) {
        debugPrint('✅ Kamera başarıyla başlatıldı - ${_cameras[_currentCameraIndex].name}');
      }
    } catch (e) {
      debugPrint('❌ Kamera başlatma hatası: $e');
    } finally {
      _isInitializing = false;
    }
  }
  
  // Kamera controller başlatma - İyileştirilmiş
  Future<void> _initController() async {
    if (_cameras.isEmpty || _currentCameraIndex >= _cameras.length) {
      debugPrint('❌ Geçerli kamera yok, controller başlatılamadı');
      return;
    }

    try {
      // Eski controller'ı temizle
      if (_controller != null) {
        await _controller!.dispose();
        _controller = null;
        _isInitialized = false;
      }
      
      // Yeni controller oluştur - Yüksek kalite ayarları
      _controller = CameraController(
        _cameras[_currentCameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      
      // Timeout ekleyerek controller başlatma
      await _controller!.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Kamera başlatma zaman aşımı');
        },
      );
      
      // Kamera yönlendirmesini kilitle
      try {
        await _controller!.lockCaptureOrientation(DeviceOrientation.portraitUp);
      } catch (e) {
        debugPrint('⚠️ Kamera yönlendirmesi kilitlenemedi: $e');
        // Bu hata kritik değil, devam et
      }
      
      // Ön kamera için optimizasyonlar
      if (_cameras[_currentCameraIndex].lensDirection == CameraLensDirection.front) {
        try {
          await Future.wait([
            _controller!.setExposureMode(ExposureMode.auto),
            _controller!.setFocusMode(FocusMode.auto),
            _controller!.setFlashMode(FlashMode.off),
          ]);
        } catch (e) {
          debugPrint('⚠️ Kamera optimizasyonları ayarlanamadı: $e');
          // Bu hatalar kritik değil, devam et
        }
      }
      
      _isInitialized = _controller!.value.isInitialized;
      debugPrint('✅ Kamera controller başarıyla başlatıldı');
    } catch (e) {
      debugPrint('❌ Kamera controller hatası: $e');
      _isInitialized = false;
      if (_controller != null) {
        await _controller!.dispose();
        _controller = null;
      }
    }
  }
  
  // Kamera önizleme widget'ı - İyileştirilmiş görüntü kalitesi
  Widget buildCameraPreview() {
    if (_controller == null || !_isInitialized || !_controller!.value.isInitialized) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Kamera başlatılıyor...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: _cameras[_currentCameraIndex].lensDirection == CameraLensDirection.front
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(3.14159), // Mirror for front camera
                  child: CameraPreview(_controller!),
                )
              : CameraPreview(_controller!),
        ),
      ),
    );
  }
  
  // Kamera değiştirme - İyileştirilmiş kamera geçişi
  Future<void> switchCamera() async {
    if (_cameras.length < 2) {
      debugPrint('⚠️ Sadece bir kamera mevcut');
      return;
    }
    
    if (_isInitializing) {
      debugPrint('⚠️ Kamera zaten başlatılıyor, bekleyin...');
      return;
    }
    
    _isInitializing = true;
    
    try {
      // Mevcut kamera tipini belirle
      final currentDirection = _cameras[_currentCameraIndex].lensDirection;
      
      // Karşıt kamera tipini bul
      int newIndex = -1;
      if (currentDirection == CameraLensDirection.front) {
        // Arka kamera ara
        newIndex = _cameras.indexWhere((camera) => 
          camera.lensDirection == CameraLensDirection.back);
      } else {
        // Ön kamera ara
        newIndex = _cameras.indexWhere((camera) => 
          camera.lensDirection == CameraLensDirection.front);
      }
      
      // Eğer karşıt kamera bulunamadıysa, sıradaki kamerayı kullan
      if (newIndex == -1) {
        newIndex = (_currentCameraIndex + 1) % _cameras.length;
      }
      
      if (newIndex != _currentCameraIndex) {
        _currentCameraIndex = newIndex;
        await _initController();
        
        if (_isInitialized && _currentCameraIndex < _cameras.length) {
          debugPrint('✅ Kamera değiştirildi: ${_cameras[_currentCameraIndex].name}');
        }
      }
    } catch (e) {
      debugPrint('❌ Kamera değiştirme hatası: $e');
    } finally {
      _isInitializing = false;
    }
  }
  
  // Belirli kamera tipini seç
  Future<void> selectCamera(CameraLensDirection direction) async {
    if (_isInitializing) {
      debugPrint('⚠️ Kamera zaten başlatılıyor, bekleyin...');
      return;
    }
    
    final cameraIndex = _cameras.indexWhere((camera) => 
      camera.lensDirection == direction);
    
    if (cameraIndex == -1) {
      debugPrint('⚠️ İstenen kamera tipi bulunamadı: $direction');
      return;
    }
    
    _isInitializing = true;
    
    try {
      if (cameraIndex != _currentCameraIndex) {
        _currentCameraIndex = cameraIndex;
        await _initController();
        
        if (_isInitialized) {
          debugPrint('✅ ${direction.name} kamera seçildi');
        }
      }
    } catch (e) {
      debugPrint('❌ Kamera seçme hatası: $e');
    } finally {
      _isInitializing = false;
    }
  }
  
  // Resim çekme
  Future<XFile?> takePicture() async {
    if (_controller == null || !_isInitialized || !_controller!.value.isInitialized) {
      debugPrint('❌ Kamera hazır değil, resim çekilemedi');
      return null;
    }
    
    try {
      // Resim çekme işlemini timeout ile koruma
      final XFile image = await _controller!.takePicture().timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw Exception('Resim çekme zaman aşımı'),
      );
      
      debugPrint('✅ Resim başarıyla çekildi: ${image.path}');
      return image;
    } catch (e) {
      debugPrint('❌ Resim çekme hatası: $e');
      return null;
    }
  }
  
  // Kamera çözünürlüğünü güncelleme
  Future<void> updateResolution(String quality) async {
    if (_controller == null || _cameras.isEmpty || _currentCameraIndex >= _cameras.length) {
      debugPrint('❌ Kamera hazır değil, çözünürlük güncellenemedi');
      return;
    }
    
    if (_isInitializing) {
      debugPrint('⚠️ Kamera zaten başlatılıyor, bekleyin...');
      return;
    }
    
    _isInitializing = true;
    
    try {
      ResolutionPreset preset;
      switch (quality.toLowerCase()) {
        case 'low':
          preset = ResolutionPreset.low;
          break;
        case 'medium':
          preset = ResolutionPreset.medium;
          break;
        case 'high':
          preset = ResolutionPreset.high;
          break;
        case 'veryHigh':
          preset = ResolutionPreset.veryHigh;
          break;
        case 'ultraHigh':
          preset = ResolutionPreset.ultraHigh;
          break;
        case 'max':
          preset = ResolutionPreset.max;
          break;
        default:
          preset = ResolutionPreset.high;
          break;
      }
      
      // Geçerli kamera ayarını kaydet
      final currentCamera = _cameras[_currentCameraIndex];
      
      // Controller'ı yeni çözünürlükle yeniden başlat
      await _controller!.dispose();
      _controller = null;
      _isInitialized = false;
      
      _controller = CameraController(
        currentCamera,
        preset,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      
      await _initController();
      debugPrint('✅ Kamera çözünürlüğü güncellendi: $quality');
    } catch (e) {
      debugPrint('❌ Çözünürlük güncelleme hatası: $e');
    } finally {
      _isInitializing = false;
    }
  }
  
  // Kaynakları temizle
  void dispose() {
    try {
      if (_controller != null) {
        _controller!.dispose();
        _controller = null;
        _isInitialized = false;
      }
      debugPrint('🧹 CameraService kaynakları temizlendi');
    } catch (e) {
      debugPrint('⚠️ Kamera kaynakları temizleme hatası: $e');
    }
  }
  
  // Kamera transform hesaplama
  Matrix4 _getCameraTransform() {
    if (_controller == null || _cameras.isEmpty || _currentCameraIndex >= _cameras.length) {
      return Matrix4.identity();
    }
    
    final camera = _cameras[_currentCameraIndex];
    final Matrix4 transform = Matrix4.identity();
    
    // Kamera sensor orientasyonunu hesapla
    final int sensorOrientation = camera.sensorOrientation;
    
    // Android cihazlarda kamera orientasyonu düzeltmesi
    if (camera.lensDirection == CameraLensDirection.front) {
      // Ön kamera için yatay ayna efekti
      transform.scale(-1.0, 1.0, 1.0);
      
      // Sensor orientasyonuna göre ek rotasyon
      if (sensorOrientation == 270) {
        transform.rotateZ(3.14159); // 180 derece
      }
    } else {
      // Arka kamera için sensor orientasyonu düzeltmesi
      if (sensorOrientation == 90) {
        transform.rotateZ(3.14159 / 2); // 90 derece
      } else if (sensorOrientation == 180) {
        transform.rotateZ(3.14159); // 180 derece
      } else if (sensorOrientation == 270) {
        transform.rotateZ(-3.14159 / 2); // -90 derece
      }
    }
    
    return transform;
  }
}