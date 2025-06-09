import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hand_speak/providers/settings_provider.dart';
import 'package:hand_speak/providers/video_provider.dart';
import 'package:hand_speak/services/camera_service.dart';
import 'package:hand_speak/services/video_service.dart';
import 'package:hand_speak/core/utils/translation_helper.dart' show T;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hand_speak/features/videos/screens/video_gallery_screen.dart';
import 'dart:math' as math;
import 'dart:async';

class ModernTranslationTab extends ConsumerStatefulWidget {
  const ModernTranslationTab({Key? key}) : super(key: key);

  @override
  ConsumerState<ModernTranslationTab> createState() => _ModernTranslationTabState();
}

class _ModernTranslationTabState extends ConsumerState<ModernTranslationTab> 
    with TickerProviderStateMixin {
  final CameraService _cameraService = CameraService();
  bool _isCameraInitialized = false;
  bool _isPermissionRequesting = false;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  int _recordDuration = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissionsAndInitCamera();
      _loadUserVideos();
    });
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _cameraService.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadUserVideos() async {
    try {
      ref.invalidate(savedVideosProvider);
    } catch (e) {
      debugPrint('❌ Video yükleme hatası: $e');
    }
  }

  Future<void> _checkPermissionsAndInitCamera() async {
    setState(() => _isPermissionRequesting = true);

    final cameraStatus = await Permission.camera.status;
    if (cameraStatus.isGranted) {
      await _initCamera();
    } else {
      await _showModernPermissionDialog();
    }

    setState(() => _isPermissionRequesting = false);
  }

  Future<void> _showModernPermissionDialog() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 24.h),
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.1),
                      Theme.of(context).primaryColor.withOpacity(0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  size: 48.sp,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                T(context, 'permissions.request_title'),
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                T(context, 'permissions.request_message'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(T(context, 'general.cancel')),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await openAppSettings();
                      },
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(T(context, 'general.settings')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _initCamera() async {
    await _cameraService.initCamera();
    setState(() => _isCameraInitialized = true);
  }

  void _startRecordingTimer() {
    _recordDuration = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordDuration++;
      });
    });
  }

  void _stopRecordingTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _recordDuration = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final videoRecordingState = ref.watch(videoRecordingStateProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final safePadding = MediaQuery.of(context).padding;

    return Scaffold(
      body: Stack(
        children: [
          // Full Screen Camera
          SizedBox(
            width: screenWidth,
            height: screenHeight,
            child: _isCameraInitialized
                ? _cameraService.buildCameraPreview()
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).primaryColor.withOpacity(0.3),
                          Theme.of(context).primaryColor.withOpacity(0.1),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            T(context, 'cameraPreparing'),
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          // Top Header
          SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // App Logo/Title
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.sign_language_rounded,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          T(context, 'appName'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Camera Switch Button
                  if (_isCameraInitialized && _cameraService.cameras.length > 1)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () async {
                          await _cameraService.switchCamera();
                          setState(() {});
                        },
                        icon: Icon(
                          Icons.flip_camera_ios_rounded,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Recording Timer
          if (videoRecordingState.isRecording)
            Positioned(
              top: safePadding.top + 80.h,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "${(_recordDuration ~/ 60).toString().padLeft(2, '0')}:${(_recordDuration % 60).toString().padLeft(2, '0')}",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Bottom Controls - En altta sabit
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                24.w, 
                20.h, 
                24.w, 
                safePadding.bottom + 16.h
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.9),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Recording Status
                  if (videoRecordingState.isRecording)
                    Container(
                      margin: EdgeInsets.only(bottom: 16.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25.r),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            T(context, 'recordingInProgress'),
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Main Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Gallery Button
                      _buildControlButton(
                        icon: Icons.photo_library_rounded,
                        label: 'Galeri',
                        onPressed: videoRecordingState.isRecording
                            ? null
                            : () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => UnifiedVideoScreen(
                                      onVideoSelected: (videoPath) async {
                                        await ref
                                            .read(videoRecordingStateProvider.notifier)
                                            .processPickedVideo(videoPath);
                                      },
                                      isSelectionMode: true,
                                    ),
                                  ),
                                );
                              },
                      ),
                      
                      // Record Button
                      GestureDetector(
                        onTap: videoRecordingState.isInitialized 
                            ? _toggleRecording 
                            : null,
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: videoRecordingState.isRecording 
                                  ? 1.0 
                                  : _pulseAnimation.value,
                              child: Container(
                                width: 70.w,
                                height: 70.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: videoRecordingState.isRecording
                                        ? [Colors.red, Colors.red.shade700]
                                        : [
                                            const Color(0xFF667EEA),
                                            const Color(0xFF764BA2),
                                          ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (videoRecordingState.isRecording 
                                          ? Colors.red 
                                          : const Color(0xFF667EEA))
                                          .withOpacity(0.3),
                                      blurRadius: 15,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  videoRecordingState.isRecording 
                                      ? Icons.stop_rounded 
                                      : Icons.videocam_rounded,
                                  color: Colors.white,
                                  size: 32.sp,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // Settings Button
                      _buildControlButton(
                        icon: Icons.settings_rounded,
                        label: 'Ayarlar',
                        onPressed: () {
                          _showCameraSettingsBottomSheet();
                        },
                      ),
                    ],
                  ),
                  
                  // Status Messages
                  if (videoRecordingState.videoUrl != null) ...[
                    SizedBox(height: 12.h),
                    _buildStatusCard(
                      icon: Icons.check_circle_rounded,
                      message: T(context, 'translatorVideoSaving'),
                      color: Colors.green,
                    ),
                  ],
                  
                  if (videoRecordingState.error != null) ...[
                    SizedBox(height: 12.h),
                    _buildStatusCard(
                      icon: Icons.error_outline_rounded,
                      message: videoRecordingState.error!,
                      color: Colors.red,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildControlButton({
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(
              icon,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatusCard({
    required IconData icon,
    required String message,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 13.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCameraSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: Theme.of(context).primaryColor,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Kamera Ayarları',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              
              // Video Quality
              _buildSettingItem(
                icon: Icons.high_quality_rounded,
                title: 'Video Kalitesi',
                subtitle: 'HD (1280x720)',
                onTap: () {},
              ),
              
              // Flash
              _buildSettingItem(
                icon: Icons.flash_on_rounded,
                title: 'Flaş',
                subtitle: 'Otomatik',
                onTap: () {},
              ),
              
              // Grid
              _buildSettingItem(
                icon: Icons.grid_on_rounded,
                title: 'Kılavuz Çizgiler',
                subtitle: 'Kapalı',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[900]
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(icon, color: Theme.of(context).primaryColor, size: 20.sp),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16.sp,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleRecording() async {
    final isRecording = ref.read(videoRecordingStateProvider).isRecording;
    if (isRecording) {
      await ref.read(videoRecordingStateProvider.notifier).stopRecording();
      _stopRecordingTimer();
      ref.invalidate(savedVideosProvider);

      // Kamera servisini temizle ve yeniden başlat
      _cameraService.dispose();
      await _cameraService.initCamera();
      setState(() {
        _isCameraInitialized = true;
      });
    } else {
      await ref.read(videoRecordingStateProvider.notifier).startRecording();
      _startRecordingTimer();
    }
  }
}