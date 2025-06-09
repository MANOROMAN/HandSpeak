import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hand_speak/models/user_model.dart';
import 'package:hand_speak/core/services/auth_service.dart';

/// Core auth service provider - singleton instance
final authServiceProvider = Provider<AuthService>((ref) => AuthService.instance);

/// Authentication state provider
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Helper provider for quick auth checks
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

// Current user provider
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final userData = await authService.getUserData();
  return userData;
});
