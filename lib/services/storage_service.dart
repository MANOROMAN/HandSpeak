import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _imagePicker = ImagePicker();

  // Pick an image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
      );
      if (pickedFile == null) return null;
      return File(pickedFile.path);
    } catch (e) {
      debugPrint('Error picking image: $e');
      throw StorageException('Error picking image: $e');
    }
  }

  // Pick an image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 800,
      );
      if (pickedFile == null) return null;
      return File(pickedFile.path);
    } catch (e) {
      debugPrint('Error taking picture: $e');
      throw StorageException('Error taking picture: $e');
    }
  }

  // Upload profile image and get download URL
  Future<String> uploadProfileImage(String userId, File imageFile) async {
    try {
      // Verify user authentication
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw StorageException('User not authenticated. Please sign in first.');
      }
      
      if (currentUser.uid != userId) {
        throw StorageException('User ID mismatch. Cannot upload for different user.');
      }
      
      // Verify file exists and is not empty
      if (!await imageFile.exists()) {
        throw StorageException('Image file does not exist');
      }
      
      final fileSize = await imageFile.length();
      if (fileSize == 0) {
        throw StorageException('Image file is empty');
      }
      
      if (fileSize > 5 * 1024 * 1024) { // 5MB limit
        throw StorageException('Image file too large. Maximum size is 5MB.');
      }
      
      debugPrint('Uploading profile image for user: $userId');
      debugPrint('File size: ${fileSize} bytes');
      debugPrint('Current user: ${currentUser.uid}');
      
      // Updated path to match Firebase Storage rules: profile_images/{userId}/{filename}
      final ref = _storage.ref().child('profile_images').child(userId).child('profile.jpg');
      
      // Upload file with progress monitoring
      final uploadTask = ref.putFile(
        imageFile, 
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploadedBy': currentUser.uid,
            'uploadedAt': DateTime.now().toIso8601String(),
          }
        )
      );
      
      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        debugPrint('Upload progress: ${progress.toStringAsFixed(1)}%');
      });
      
      // Wait for completion
      final snapshot = await uploadTask;
      debugPrint('Upload completed. State: ${snapshot.state}');
      
      // Get download URL
      final downloadUrl = await ref.getDownloadURL();
      debugPrint('Download URL obtained: $downloadUrl');
      
      return downloadUrl;
    } on FirebaseException catch (e) {
      debugPrint('Firebase Storage Error: ${e.code} - ${e.message}');
      
      switch (e.code) {
        case 'unauthorized':
          throw StorageException('Not authorized to upload. Please check your permissions and try again.');
        case 'canceled':
          throw StorageException('Upload was canceled');
        case 'unknown':
          throw StorageException('Unknown error occurred during upload: ${e.message}');
        case 'quota-exceeded':
          throw StorageException('Storage quota exceeded');
        case 'retry-limit-exceeded':
          throw StorageException('Upload retry limit exceeded. Please try again later.');
        default:
          throw StorageException('Upload failed: ${e.message}');
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
      throw StorageException('Error uploading image: $e');
    }
  }

  // Delete profile image
  Future<void> deleteProfileImage(String userId) async {
    try {
      // Updated path to match Firebase Storage rules: profile_images/{userId}/{filename}
      final ref = _storage.ref().child('profile_images').child(userId).child('profile.jpg');
      await ref.delete();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') {
        throw StorageException('Error deleting image: $e');
      }
    }
  }

  // Test storage permissions and connectivity
  Future<bool> testStoragePermissions() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        debugPrint('❌ No user authenticated for storage test');
        return false;
      }
      
      debugPrint('🔍 Testing storage permissions for user: ${currentUser.uid}');
      
      // Test write permission by uploading a small test file
      final testRef = _storage.ref()
          .child('profile_images')
          .child(currentUser.uid)
          .child('test_permission.txt');
      
      final testData = 'test_${DateTime.now().millisecondsSinceEpoch}';
      
      await testRef.putString(
        testData,
        metadata: SettableMetadata(
          contentType: 'text/plain',
          customMetadata: {
            'test': 'true',
            'createdAt': DateTime.now().toIso8601String(),
          }
        )
      );
      
      debugPrint('✅ Write permission test passed');
      
      // Test read permission
      final downloadUrl = await testRef.getDownloadURL();
      debugPrint('✅ Read permission test passed: $downloadUrl');
      
      // Clean up test file
      await testRef.delete();
      debugPrint('✅ Delete permission test passed');
      
      return true;
    } catch (e) {
      debugPrint('❌ Storage permission test failed: $e');
      return false;
    }
  }
}

class StorageException implements Exception {
  final String message;
  StorageException(this.message);
  
  @override
  String toString() => 'StorageException: $message';
}
