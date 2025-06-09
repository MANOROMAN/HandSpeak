import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hand_speak/models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:hand_speak/core/services/email_auth_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  static AuthService get instance => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Google Sign-In configuration with web client ID
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '231396145380-pukspnjfg14appibvf5qqboc0pgupfje.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user
  User? get currentUser => _auth.currentUser;

  // Get user data from Firestore
  Future<UserModel?> getUserData() async {
    try {
      if (currentUser == null) return null;
      
      final doc = await _firestore.collection('users').doc(currentUser!.uid).get();
      
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return UserModel.fromMap(data);
      }
      
      // Create new user profile if doesn't exist
      return await _createUserProfile(currentUser!);
    } catch (e) {
      debugPrint('❌ Error getting user data: $e');
      return null;
    }
  }

  // Create user profile in Firestore
  Future<UserModel?> _createUserProfile(User user) async {
    try {
      String firstName = 'Kullanıcı';
      String lastName = '';

      if (user.displayName != null && user.displayName!.isNotEmpty) {
        final nameParts = user.displayName!.split(' ');
        firstName = nameParts[0];
        if (nameParts.length > 1) {
          lastName = nameParts.sublist(1).join(' ');
        }
      }

      final userModel = UserModel(
        id: user.uid,
        firstName: firstName,
        lastName: lastName,
        email: user.email ?? '',
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
        isEmailVerified: user.emailVerified,
        birthDate: null,
      );

      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
      debugPrint('✅ User profile created in Firestore');
      
      return userModel;
    } catch (e) {
      debugPrint('❌ Error creating user profile: $e');
      return null;
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      debugPrint('🔄 Starting email registration for: $email');
      
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Update display name
        await userCredential.user!.updateDisplayName('$firstName $lastName');
        
        // Create user profile in Firestore
        await _createUserProfile(userCredential.user!);
        
        debugPrint('✅ Email registration successful');
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Email registration error: ${e.code} - ${e.message}');
      throw FirebaseAuthException(
        code: e.code,
        message: _getAuthErrorMessage(e.code),
      );
    } catch (e) {
      debugPrint('❌ Unexpected registration error: $e');
      throw Exception('Kayıt sırasında beklenmeyen bir hata oluştu');
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔄 Starting email sign in for: $email');
      
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint('✅ Email sign in successful');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Email sign in error: ${e.code} - ${e.message}');
      throw FirebaseAuthException(
        code: e.code,
        message: _getAuthErrorMessage(e.code),
      );
    } catch (e) {
      debugPrint('❌ Unexpected sign in error: $e');
      throw Exception('Giriş sırasında beklenmeyen bir hata oluştu');
    }
  }

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      debugPrint('🔄 Starting Google Sign In');
      
      // Sign out first to ensure clean state
      await _googleSignIn.signOut();
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        debugPrint('ℹ️ Google Sign In cancelled by user');
        return null;
      }

      debugPrint('✅ Google account selected: ${googleUser.email}');
      
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        debugPrint('❌ Failed to get Google auth tokens');
        throw Exception('Google kimlik doğrulama başarısız');
      }

      debugPrint('✅ Google auth tokens obtained');
      
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      debugPrint('✅ Firebase credential created');
      
      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        // Create user profile if new user
        if (userCredential.additionalUserInfo?.isNewUser == true) {
          await _createUserProfile(userCredential.user!);
        }
        
        debugPrint('✅ Google Sign In completely successful: ${userCredential.user!.email}');
        return userCredential.user;
      }
      
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth error during Google Sign In: ${e.code} - ${e.message}');
      throw FirebaseAuthException(
        code: e.code,
        message: _getAuthErrorMessage(e.code),
      );
    } catch (e) {
      debugPrint('❌ Unexpected Google Sign In error: $e');
      throw Exception('Google ile giriş sırasında hata oluştu: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      debugPrint('✅ Sign out successful');
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
    }
  }

  // E-posta doğrulama kodu gönderme
  Future<void> sendVerificationCode(String email) async {
    try {
      final emailAuthService = EmailAuthService.instance;
      await emailAuthService.sendVerificationCode(email);
    } catch (e) {
      debugPrint('❌ Error sending verification code: $e');
      rethrow;
    }
  }
  
  // E-posta doğrulama kodunu kontrol etme
  Future<bool> verifyEmailCode({required String email, required String code}) async {
    try {
      final emailAuthService = EmailAuthService.instance;
      return await emailAuthService.verifyCode(email, code);
    } catch (e) {
      debugPrint('❌ Error verifying code: $e');
      rethrow;
    }
  }

  /// Mark the current user's email as verified in Firestore
  Future<void> markEmailVerified(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isEmailVerified': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await _auth.currentUser?.reload();
      debugPrint('✅ Email marked as verified for $userId');
    } catch (e) {
      debugPrint('❌ Error updating email verification status: $e');
      rethrow;
    }
  }
  
  // E-posta ve doğrulama koduyla giriş yapma
  Future<UserCredential> signInWithEmailAndCode({
    required String email, 
    required String code,
    required String password,
  }) async {
    try {
      // Önce kodu doğrula
      final verified = await verifyEmailCode(email: email, code: code);
      
      if (!verified) {
        throw Exception('Doğrulama kodu geçersiz');
      }
      
      // Doğrulama başarılı, normal giriş yap
      return await signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      debugPrint('❌ Error signing in with email and code: $e');
      rethrow;
    }
  }
  
  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint('✅ Password reset email sent');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Password reset error: ${e.code} - ${e.message}');
      throw FirebaseAuthException(
        code: e.code,
        message: _getAuthErrorMessage(e.code),
      );
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint('✅ Password reset email sent to $email');
    } catch (e) {
      debugPrint('❌ Error sending password reset email: $e');
      rethrow;
    }
  }

  // Update profile photo
  Future<void> updateProfilePhoto(String userId, String? photoUrl) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Also update Firebase Auth profile
      if (currentUser != null) {
        await currentUser!.updatePhotoURL(photoUrl);
      }
      
      debugPrint('✅ Profile photo updated for user $userId');
    } catch (e) {
      debugPrint('❌ Error updating profile photo: $e');
      rethrow;
    }
  }

  // Update user name and birth date
  Future<void> updateUserName(String userId, String firstName, String lastName,
      {DateTime? birthDate}) async {
    try {
      final data = {
        'firstName': firstName,
        'lastName': lastName,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (birthDate != null) {
        data['birthDate'] = Timestamp.fromDate(birthDate);
      }
      await _firestore.collection('users').doc(userId).update(data);
      
      // Also update Firebase Auth profile
      if (currentUser != null) {
        await currentUser!.updateDisplayName('$firstName $lastName');
      }
      
      debugPrint('✅ User name updated for user $userId');
    } catch (e) {
      debugPrint('❌ Error updating user name: $e');
      rethrow;
    }
  }

  // Change password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: currentPassword,
      );
      
      await currentUser!.reauthenticateWithCredential(credential);
      
      // Update password
      await currentUser!.updatePassword(newPassword);
      
      debugPrint('✅ Password changed successfully');
    } catch (e) {
      debugPrint('❌ Error changing password: $e');
      rethrow;
    }
  }

  // Get user-friendly error messages
  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Bu e-posta adresine kayıtlı kullanıcı bulunamadı.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanımda.';
      case 'weak-password':
        return 'Password is too weak. Must be at least 6 characters.';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi.';
      case 'user-disabled':
        return 'Bu kullanıcı hesabı devre dışı bırakılmış.';
      case 'too-many-requests':
        return 'Çok fazla deneme. Lütfen daha sonra tekrar deneyin.';
      case 'operation-not-allowed':
        return 'Bu işlem şu anda izin verilmiyor.';
      case 'invalid-credential':
        return 'Geçersiz kimlik bilgileri.';
      case 'account-exists-with-different-credential':
        return 'Bu e-posta adresi farklı bir giriş yöntemi ile kayıtlı.';
      case 'invalid-verification-code':
        return 'Geçersiz doğrulama kodu.';
      case 'invalid-verification-id':
        return 'Geçersiz doğrulama ID\'si.';
      default:
        return 'Bir hata oluştu. Lütfen tekrar deneyin.';
    }
  }
}