import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

class StorageTestHelper {
  static final _auth = FirebaseAuth.instance;
  static final _storage = FirebaseStorage.instance;

  /// Test basic Firebase Storage connectivity
  static Future<String> testBasicConnectivity() async {
    try {
      // Check if user is authenticated
      final user = _auth.currentUser;
      if (user == null) {
        return '❌ No authenticated user';
      }

      // Try to get ID token
      final token = await user.getIdToken(true);
      
      return '✅ Basic connectivity OK\n'
             '   User: ${user.uid}\n'
             '   Token length: ${token?.length ?? 0}';
    } catch (e) {
      return '❌ Basic connectivity failed: $e';
    }
  }

  /// Test profile image upload permissions
  static Future<String> testProfileImageUpload() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return '❌ No authenticated user for profile image test';
      }

      // Create a small test image file
      final testImageFile = await _createTestImageFile();
      
      // Try to upload to profile_images/{userId}/test.jpg
      final ref = _storage.ref()
          .child('profile_images')
          .child(user.uid)
          .child('test.jpg');

      await ref.putFile(testImageFile);
      final downloadUrl = await ref.getDownloadURL();
      
      // Clean up test file
      await ref.delete();
      await testImageFile.delete();

      return '✅ Profile image upload test passed\n'
             '   Path: profile_images/${user.uid}/test.jpg\n'
             '   URL obtained: ${downloadUrl.isNotEmpty}';
    } catch (e) {
      return '❌ Profile image upload test failed: $e';
    }
  }

  /// Test video upload permissions
  static Future<String> testVideoUpload() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return '❌ No authenticated user for video test';
      }

      // Create a small test video file
      final testVideoFile = await _createTestVideoFile();
      
      // Try to upload to videos/{userId}/test.mp4
      final ref = _storage.ref()
          .child('videos')
          .child(user.uid)
          .child('test.mp4');

      await ref.putFile(testVideoFile);
      final downloadUrl = await ref.getDownloadURL();
      
      // Clean up test file
      await ref.delete();
      await testVideoFile.delete();

      return '✅ Video upload test passed\n'
             '   Path: videos/${user.uid}/test.mp4\n'
             '   URL obtained: ${downloadUrl.isNotEmpty}';
    } catch (e) {
      return '❌ Video upload test failed: $e';
    }
  }

  /// Create a minimal test image file
  static Future<File> _createTestImageFile() async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/test_image.jpg');
    
    // Create a minimal JPEG header (valid but minimal image)
    final jpegHeader = [
      0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01,
      0x01, 0x01, 0x00, 0x48, 0x00, 0x48, 0x00, 0x00, 0xFF, 0xDB, 0x00, 0x43,
      0x00, 0x08, 0x06, 0x06, 0x07, 0x06, 0x05, 0x08, 0x07, 0x07, 0x07, 0x09,
      0xFF, 0xD9 // End of Image
    ];
    
    await file.writeAsBytes(jpegHeader);
    return file;
  }

  /// Create a minimal test video file
  static Future<File> _createTestVideoFile() async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/test_video.mp4');
    
    // Create minimal MP4 header
    final mp4Header = [
      0x00, 0x00, 0x00, 0x20, 0x66, 0x74, 0x79, 0x70, 0x69, 0x73, 0x6F, 0x6D,
      0x00, 0x00, 0x02, 0x00, 0x69, 0x73, 0x6F, 0x6D, 0x69, 0x73, 0x6F, 0x32,
      0x6D, 0x70, 0x34, 0x31, 0x00, 0x00, 0x00, 0x08, 0x66, 0x72, 0x65, 0x65
    ];
    
    await file.writeAsBytes(mp4Header);
    return file;
  }

  /// Run all tests sequentially
  static Future<List<String>> runAllTests() async {
    final results = <String>[];
    
    results.add('🔬 Running Firebase Storage Tests...\n');
    
    results.add(await testBasicConnectivity());
    results.add('');
    
    results.add(await testProfileImageUpload());
    results.add('');
    
    results.add(await testVideoUpload());
    results.add('');
    
    results.add('🏁 Tests completed');
    
    return results;
  }
}
