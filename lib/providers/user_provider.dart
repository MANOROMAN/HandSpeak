import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hand_speak/models/user_model.dart';
import 'package:hand_speak/core/services/auth_service.dart';
import 'package:hand_speak/providers/auth_provider.dart';

/// User profile notifier provider - depends on authServiceProvider
final userProvider = AsyncNotifierProvider<UserProfileNotifier, UserModel?>(() {
  return UserProfileNotifier();
});

class UserProfileNotifier extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    // Listen to auth state changes
    final authState = ref.watch(authStateProvider);
    
    return authState.when(
      data: (user) async {
        if (user == null) {
          debugPrint('👤 User not authenticated, returning null');
          return null;
        }
        
        debugPrint('👤 User authenticated: ${user.uid}, fetching profile data');
        final authService = ref.read(authServiceProvider);
        final userData = await authService.getUserData();
        debugPrint('👤 User data loaded: ${userData?.name ?? 'No name'}');
        return userData;
      },
      loading: () => null,
      error: (_, __) => null,
    );
  }

  // Refresh user profile
  Future<void> refreshUserProfile() async {
    state = const AsyncValue.loading();
    try {
      final authService = ref.read(authServiceProvider);
      final userData = await authService.getUserData();
      state = AsyncValue.data(userData);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Update profile photo
  Future<void> updateProfilePhoto(String? photoUrl) async {
    final currentUser = state.valueOrNull;
    if (currentUser == null) return;
    try {
      final authService = ref.read(authServiceProvider);
      await authService.updateProfilePhoto(currentUser.id, photoUrl);
      await refreshUserProfile();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeProfilePhoto() async {
    final currentUser = state.valueOrNull;
    if (currentUser == null) return;
    try {
      final authService = ref.read(authServiceProvider);
      await authService.updateProfilePhoto(currentUser.id, null);
      await refreshUserProfile();
    } catch (e) {
      rethrow;
    }
  }

  // Update user name
  Future<void> updateUserName(String firstName, String lastName) async {
    final currentUser = state.valueOrNull;
    if (currentUser == null) return;
    try {
      final authService = ref.read(authServiceProvider);
      await authService.updateUserName(currentUser.id, firstName, lastName);
      await refreshUserProfile();
    } catch (e) {
      rethrow;
    }
  }

  // Change password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.changePassword(currentPassword, newPassword);
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    final authService = ref.read(authServiceProvider);
    await authService.signOut();
    state = const AsyncValue.data(null);
  }
}
