import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GalleryService {
  final ImagePicker _picker = ImagePicker();
  
  // Galeriden görüntü seçme
  Future<XFile?> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      return image;
    } catch (e) {
      debugPrint('Galeri seçim hatası: $e');
      return null;
    }
  }
  
  // Galeriden video seçme
  Future<XFile?> pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
      );
      return video;
    } catch (e) {
      debugPrint('Video seçim hatası: $e');
      return null;
    }
  }
}
