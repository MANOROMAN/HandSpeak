import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hand_speak/providers/user_provider.dart';
import 'package:hand_speak/core/utils/translation_helper.dart';
import 'dart:io';
import 'package:hand_speak/providers/storage_provider.dart';

class ProfilePhotoUploadWidget extends ConsumerWidget {
  const ProfilePhotoUploadWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    
    return userAsync.when(
      data: (user) {
        return GestureDetector(
          onTap: () => _showImageSourceDialog(context, ref),
          child: Container(
            width: 120.w,
            height: 120.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[300]!, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipOval(
              child: user?.photoUrl != null
                  ? Image.network(
                      user!.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultAvatar(context);
                      },
                    )
                  : _buildDefaultAvatar(context),
            ),
          ),
        );
      },
      loading: () => Container(
        width: 120.w,
        height: 120.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[200],
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => _buildDefaultAvatar(context),
    );
  }

  Widget _buildDefaultAvatar(BuildContext context) {
    return Container(
      width: 120.w,
      height: 120.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).primaryColor.withOpacity(0.1),
      ),
      child: Icon(
        Icons.person,
        size: 60.sp,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Future<void> _showImageSourceDialog(BuildContext context, WidgetRef ref) async {
    final user = ref.read(userProvider).valueOrNull;
    return showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Container(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                T(context, 'auth.profile_photo_select'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildSourceOption(
                      context,
                      icon: Icons.camera_alt,
                      title: T(context, 'auth.take_photo'),
                      onTap: () => _pickImageFromCamera(context, ref),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSourceOption(
                      context,
                      icon: Icons.photo_library,
                      title: T(context, 'auth.select_from_gallery'),
                      onTap: () => _pickImageFromGallery(context, ref),
                    ),
                  ),
                ],
              ),
              if (user?.photoUrl != null) ...[
                SizedBox(height: 16.h),
                _buildSourceOption(
                  context,
                  icon: Icons.delete,
                  title: T(context, 'profile.remove_photo'),
                  onTap: () => _removeProfilePhoto(context, ref),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32.sp,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromCamera(BuildContext context, WidgetRef ref) async {
    Navigator.pop(context);
    final storage = ref.read(storageServiceProvider);
    final file = await storage.pickImageFromCamera();

    if (file != null) {
      await _uploadProfilePhoto(context, ref, file);
    }
  }

  Future<void> _pickImageFromGallery(BuildContext context, WidgetRef ref) async {
    Navigator.pop(context);
    final storage = ref.read(storageServiceProvider);
    final file = await storage.pickImageFromGallery();

    if (file != null) {
      await _uploadProfilePhoto(context, ref, file);
    }
  }

  Future<void> _uploadProfilePhoto(BuildContext context, WidgetRef ref, File imageFile) async {
    try {
      final user = ref.read(userProvider).valueOrNull;
      if (user == null) return;
      final storage = ref.read(storageServiceProvider);
      final downloadUrl = await storage.uploadProfileImage(user.id, imageFile);

      await ref.read(userProvider.notifier).updateProfilePhoto(downloadUrl);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(T(context, 'auth.profile_photo_updated')),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${T(context, 'errors.general_error')}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeProfilePhoto(BuildContext context, WidgetRef ref) async {
    Navigator.pop(context);
    try {
      final user = ref.read(userProvider).valueOrNull;
      if (user == null) return;
      final storage = ref.read(storageServiceProvider);
      await storage.deleteProfileImage(user.id);
      await ref.read(userProvider.notifier).removeProfilePhoto();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(T(context, 'auth.profile_photo_updated')),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${T(context, 'errors.general_error')}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
