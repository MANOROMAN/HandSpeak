import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class FirebaseStorageDebug {
  static Future<void> runFullDebug() async {
    print('🔍 === FIREBASE STORAGE DEBUG SESSION ===');
    print('🕒 Time: ${DateTime.now()}');
    print('');
    
    try {
      // Check authentication status
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print('✅ USER AUTHENTICATION:');
        print('   🆔 User ID: ${user.uid}');
        print('   📧 Email: ${user.email ?? "No email"}');
        print('   👤 Display Name: ${user.displayName ?? "No display name"}');
        print('   🔐 Email Verified: ${user.emailVerified}');
        print('   🕒 Creation Time: ${user.metadata.creationTime}');
        print('   🔄 Last Sign In: ${user.metadata.lastSignInTime}');
        print('');

        // Test storage access
        print('📤 UPLOAD PERMISSION TEST:');
        final uploadSuccess = await testUploadPermission(user.uid);
        if (uploadSuccess) {
          print('   ✅ Upload test successful');
        } else {
          print('   ❌ Upload test failed');
        }
        print('');
      } else {
        print('❌ No authenticated user found');
        print('');
      }
      
      print('🏁 === DEBUG SESSION COMPLETE ===');
      print('');
      
    } catch (e) {
      print('💥 CRITICAL DEBUG ERROR: $e');
      print('🏁 === DEBUG SESSION FAILED ===');
      print('');
    }
  }
  
  static Future<bool> testUploadPermission(String userId) async {
    try {
      print('   🔍 Testing upload to: profile_images/$userId/test.txt');
      final storage = FirebaseStorage.instance;
      final testRef = storage.ref().child('profile_images').child(userId).child('test.txt');
      
      // Try to upload a small test file
      final testData = 'Firebase Storage Test - ${DateTime.now()}';
      await testRef.putString(testData);
      print('   ✅ Test file uploaded successfully');
      
      // Try to get download URL
      final downloadUrl = await testRef.getDownloadURL();
      print('   ✅ Download URL obtained: ${downloadUrl.substring(0, 50)}...');
      
      // Clean up test file
      await testRef.delete();
      print('   ✅ Test file cleaned up');
      
      return true;
      
    } catch (e) {
      debugPrint('❌ Upload permission test failed: $e');
      return false;
    }
  }
}
