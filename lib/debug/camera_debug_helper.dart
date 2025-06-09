import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:camera/camera.dart';
import 'dart:io';

class CameraDebugHelper {
  static Future<void> debugCameraAndFirebase() async {
    debugPrint('🔍 === CAMERA & FIREBASE DEBUG SESSION ===');
    
    try {
      // 1. Check Firebase Authentication
      debugPrint('\n1️⃣ AUTHENTICATION CHECK:');
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        debugPrint('   ✅ User authenticated: ${user.uid}');
        debugPrint('   📧 Email: ${user.email}');
        debugPrint('   🔑 Anonymous: ${user.isAnonymous}');
        
        // Test ID Token
        try {
          final token = await user.getIdToken(true);
          debugPrint('   ✅ ID Token obtained (length: ${token.length})');
        } catch (e) {
          debugPrint('   ❌ ID Token error: $e');
        }
      } else {
        debugPrint('   ❌ No user authenticated');
        return;
      }
      
      // 2. Check Camera Access
      debugPrint('\n2️⃣ CAMERA ACCESS CHECK:');
      try {
        final cameras = await availableCameras();
        debugPrint('   ✅ Found ${cameras.length} cameras');
        
        for (int i = 0; i < cameras.length; i++) {
          final camera = cameras[i];
          debugPrint('   📸 Camera $i: ${camera.name}');
          debugPrint('      - Direction: ${camera.lensDirection}');
          debugPrint('      - Sensor Orientation: ${camera.sensorOrientation}°');
        }
      } catch (e) {
        debugPrint('   ❌ Camera access error: $e');
      }
      
      // 3. Test Firestore Permissions
      debugPrint('\n3️⃣ FIRESTORE PERMISSIONS TEST:');
      try {
        // Test creating a video document
        final testDoc = await FirebaseFirestore.instance
            .collection('videos')
            .add({
          'userId': user.uid,
          'fileName': 'test_video.mp4',
          'downloadUrl': 'https://example.com/test.mp4',
          'uploadedAt': FieldValue.serverTimestamp(),
          'size': 1024,
          'duration': 5,
          'testDocument': true,
        });
        
        debugPrint('   ✅ Firestore write successful: ${testDoc.id}');
        
        // Clean up test document
        await testDoc.delete();
        debugPrint('   ✅ Test document cleaned up');
      } catch (e) {
        debugPrint('   ❌ Firestore permission error: $e');
        debugPrint('      This is likely the source of your permission denied error!');
      }
      
      // 4. Test Storage Permissions
      debugPrint('\n4️⃣ STORAGE PERMISSIONS TEST:');
      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('videos')
            .child(user.uid)
            .child('test_file.txt');
        
        await ref.putString('Test data');
        debugPrint('   ✅ Storage upload successful');
        
        final url = await ref.getDownloadURL();
        debugPrint('   ✅ Download URL: ${url.substring(0, 50)}...');
        
        // Clean up
        await ref.delete();
        debugPrint('   ✅ Test file cleaned up');
      } catch (e) {
        debugPrint('   ❌ Storage permission error: $e');
      }
      
      // 5. Test Camera Initialization
      debugPrint('\n5️⃣ CAMERA INITIALIZATION TEST:');
      try {
        final cameras = await availableCameras();
        if (cameras.isNotEmpty) {
          final camera = cameras.first;
          final controller = CameraController(
            camera,
            ResolutionPreset.medium,
            enableAudio: true,
            imageFormatGroup: Platform.isAndroid
                ? ImageFormatGroup.nv21
                : ImageFormatGroup.bgra8888,
          );
          
          await controller.initialize();
          debugPrint('   ✅ Camera controller initialized successfully');
          debugPrint('   📐 Preview size: ${controller.value.previewSize}');
          debugPrint('   🎥 Is initialized: ${controller.value.isInitialized}');
          
          await controller.dispose();
          debugPrint('   ✅ Camera controller disposed');
        }
      } catch (e) {
        debugPrint('   ❌ Camera initialization error: $e');
      }
      
    } catch (e) {
      debugPrint('💥 CRITICAL DEBUG ERROR: $e');
    }
    
    debugPrint('\n🏁 === DEBUG SESSION COMPLETE ===\n');
  }
  
  static Future<void> testVideoRecording() async {
    debugPrint('🎬 === VIDEO RECORDING TEST ===');
    
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint('❌ No cameras available');
        return;
      }
      
      final camera = cameras.first;
      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: true,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );
      
      await controller.initialize();
      debugPrint('✅ Camera initialized for recording test');
      
      // Test short recording
      await controller.startVideoRecording();
      debugPrint('✅ Recording started');
      
      await Future.delayed(const Duration(seconds: 2));
      
      final video = await controller.stopVideoRecording();
      debugPrint('✅ Recording stopped');
      debugPrint('📁 Video path: ${video.path}');
      
      // Check file
      final file = File(video.path);
      if (await file.exists()) {
        final size = await file.length();
        debugPrint('✅ Video file exists (${size} bytes)');
        
        // Clean up
        await file.delete();
        debugPrint('✅ Test video file cleaned up');
      } else {
        debugPrint('❌ Video file does not exist');
      }
      
      await controller.dispose();
      debugPrint('✅ Camera disposed');
      
    } catch (e) {
      debugPrint('❌ Video recording test error: $e');
    }
    
    debugPrint('🏁 === VIDEO RECORDING TEST COMPLETE ===\n');
  }
}
