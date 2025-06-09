import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hand_speak/models/video_quality_settings.dart';
import 'package:hand_speak/providers/video_quality_provider.dart';
import 'package:hand_speak/core/utils/translation_helper.dart' show T;

class VideoSettingsBottomSheet extends ConsumerStatefulWidget {
  const VideoSettingsBottomSheet({Key? key}) : super(key: key);

  @override
  ConsumerState<VideoSettingsBottomSheet> createState() => _VideoSettingsBottomSheetState();
}

class _VideoSettingsBottomSheetState extends ConsumerState<VideoSettingsBottomSheet> 
    with TickerProviderStateMixin {
  late VideoQualitySettings _currentSettings;
  late AnimationController _animationController;
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  bool _isSaving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _currentSettings = ref.read(videoQualityProvider);
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _slideController.forward();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _updateSettings(VideoQualitySettings newSettings) {
    setState(() {
      _currentSettings = newSettings;
      _hasChanges = newSettings != ref.read(videoQualityProvider);
    });
  }

  Future<void> _saveSettings() async {
    if (_isSaving || !_hasChanges) return;
    
    setState(() => _isSaving = true);
    
    try {
      await ref.read(videoQualityProvider.notifier).updateSettings(
        resolution: _currentSettings.resolution,
        frameRate: _currentSettings.frameRate,
        enableAudio: _currentSettings.enableAudio,
      );
      
      if (mounted) {
        _showSuccessMessage();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage();
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                color: Colors.green,
                size: 16.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'Ayarlar başarıyla kaydedildi',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }

  void _showErrorMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 16.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'Ayarlar kaydedilemedi',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(_slideAnimation),
        child: DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) => Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.5 : 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  children: [
                    // Handle bar
                    Container(
                      margin: EdgeInsets.only(top: 12.h),
                      width: 50.w,
                      height: 5.h,
                      decoration: BoxDecoration(
                        color: theme.dividerColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(2.5.r),
                      ),
                    ),
                    
                    // Header
                    Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                            ? [
                                theme.primaryColor.withOpacity(0.2),
                                theme.primaryColor.withOpacity(0.1),
                              ]
                            : [
                                theme.primaryColor.withOpacity(0.1),
                                theme.primaryColor.withOpacity(0.05),
                              ],
                        ),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                        border: Border.all(
                          color: theme.primaryColor.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60.w,
                            height: 60.w,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  theme.primaryColor,
                                  theme.primaryColor.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.primaryColor.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.videocam_rounded,
                              color: Colors.white,
                              size: 28.sp,
                            ),
                          ),
                          SizedBox(width: 20.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Video Ayarları',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.primaryColor,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Kalite ve performans ayarları',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: theme.cardColor.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icon(
                                Icons.close_rounded,
                                color: theme.iconTheme.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Content
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: EdgeInsets.all(24.w),
                        children: [
                          // Video Quality Section
                          _buildSectionCard(
                            title: 'Video Kalitesi',
                            description: 'Kayıt çözünürlüğü ve görüntü kalitesi ayarları',
                            icon: Icons.high_quality_rounded,
                            iconColor: Colors.blue,
                            children: [
                              ...VideoQualitySettings.qualityOptions.map((option) {
                                final ResolutionPreset value = option['value'] as ResolutionPreset;
                                final String label = option['label'] as String;
                                final isSelected = _currentSettings.resolution == value;
                                
                                return Container(
                                  margin: EdgeInsets.only(bottom: 12.h),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(
                                      color: isSelected 
                                        ? theme.primaryColor 
                                        : theme.dividerColor.withOpacity(0.3),
                                      width: isSelected ? 2 : 1,
                                    ),
                                    gradient: isSelected 
                                      ? LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            theme.primaryColor.withOpacity(0.1),
                                            theme.primaryColor.withOpacity(0.05),
                                          ],
                                        )
                                      : null,
                                    color: isSelected ? null : theme.cardColor,
                                    boxShadow: isSelected ? [
                                      BoxShadow(
                                        color: theme.primaryColor.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ] : null,
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        _updateSettings(_currentSettings.copyWith(
                                          resolution: value,
                                        ));
                                      },
                                      borderRadius: BorderRadius.circular(16.r),
                                      child: Padding(
                                        padding: EdgeInsets.all(16.w),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 24.w,
                                              height: 24.w,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: isSelected 
                                                    ? theme.primaryColor 
                                                    : theme.dividerColor,
                                                  width: 2,
                                                ),
                                                color: isSelected 
                                                  ? theme.primaryColor 
                                                  : Colors.transparent,
                                              ),
                                              child: isSelected 
                                                ? Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                    size: 16.sp,
                                                  )
                                                : null,
                                            ),
                                            SizedBox(width: 16.w),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    label,
                                                    style: theme.textTheme.titleSmall?.copyWith(
                                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                                      color: isSelected ? theme.primaryColor : null,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4.h),
                                                  Text(
                                                    _getQualityDescription(value),
                                                    style: theme.textTheme.bodySmall?.copyWith(
                                                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (isSelected)
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                                decoration: BoxDecoration(
                                                  color: theme.primaryColor,
                                                  borderRadius: BorderRadius.circular(8.r),
                                                ),
                                                child: Text(
                                                  'Seçili',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10.sp,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                          
                          SizedBox(height: 24.h),
                          
                          // Audio Settings Section
                          _buildSectionCard(
                            title: 'Ses Ayarları',
                            description: 'Video kayıtlarında ses alma ayarları',
                            icon: Icons.mic_rounded,
                            iconColor: Colors.orange,
                            children: [
                              Container(
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16.r),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: _currentSettings.enableAudio
                                      ? [
                                          Colors.green.withOpacity(0.1),
                                          Colors.green.withOpacity(0.05),
                                        ]
                                      : [
                                          theme.dividerColor.withOpacity(0.1),
                                          theme.dividerColor.withOpacity(0.05),
                                        ],
                                  ),
                                  border: Border.all(
                                    color: _currentSettings.enableAudio
                                      ? Colors.green.withOpacity(0.3)
                                      : theme.dividerColor.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(12.w),
                                      decoration: BoxDecoration(
                                        color: _currentSettings.enableAudio
                                          ? Colors.green.withOpacity(0.2)
                                          : theme.dividerColor.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      child: Icon(
                                        _currentSettings.enableAudio 
                                          ? Icons.mic_rounded 
                                          : Icons.mic_off_rounded,
                                        color: _currentSettings.enableAudio 
                                          ? Colors.green 
                                          : theme.dividerColor,
                                        size: 24.sp,
                                      ),
                                    ),
                                    SizedBox(width: 16.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Ses Kaydı',
                                            style: theme.textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: _currentSettings.enableAudio 
                                                ? Colors.green 
                                                : theme.textTheme.titleSmall?.color,
                                            ),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            _currentSettings.enableAudio 
                                              ? 'Video ile birlikte ses kaydedilir'
                                              : 'Sadece görüntü kaydedilir',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Switch.adaptive(
                                      value: _currentSettings.enableAudio,
                                      activeColor: Colors.green,
                                      onChanged: (bool value) {
                                        _updateSettings(_currentSettings.copyWith(
                                          enableAudio: value,
                                        ));
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 24.h),
                          
                          // Storage Info Section
                          _buildInfoCard(),
                          
                          SizedBox(height: 24.h),
                          
                          // Performance Tips
                          _buildPerformanceTips(),
                          
                          SizedBox(height: 100.h), // Space for bottom buttons
                        ],
                      ),
                    ),
                    
                    // Bottom Actions
                    Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        border: Border(
                          top: BorderSide(
                            color: theme.dividerColor.withOpacity(0.2),
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                            blurRadius: 15,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _hasChanges ? () {
                                  setState(() {
                                    _currentSettings = const VideoQualitySettings();
                                    _hasChanges = true;
                                  });
                                } : null,
                                icon: Icon(Icons.restore_rounded, size: 20.sp),
                                label: Text(
                                  'Varsayılan',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  side: BorderSide(
                                    color: theme.dividerColor,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              flex: 2,
                              child: FilledButton.icon(
                                onPressed: _hasChanges && !_isSaving ? _saveSettings : null,
                                icon: _isSaving 
                                  ? SizedBox(
                                      width: 20.w,
                                      height: 20.w,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Icon(Icons.save_rounded, size: 20.sp),
                                label: Text(
                                  _isSaving ? 'Kaydediliyor...' : 'Kaydet',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: theme.primaryColor,
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  elevation: 8,
                                  shadowColor: theme.primaryColor.withOpacity(0.3),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: theme.cardColor,
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: iconColor, size: 24.sp),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: iconColor,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.w),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withOpacity(0.1),
            Colors.purple.withOpacity(0.1),
          ],
        ),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.purple],
              ),
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.storage_rounded,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Depolama İpucu',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Yüksek kalite daha fazla depolama alanı kullanır. Cihazınızın depolama durumunu kontrol edin.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTips() {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.withOpacity(0.1),
            Colors.teal.withOpacity(0.1),
          ],
        ),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green, Colors.teal],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.tips_and_updates_rounded,
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Text(
                'Performans İpuçları',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildTipItem('Düşük pil durumunda düşük kalite kullanın'),
          _buildTipItem('Zayıf internet bağlantısında ses kaydını kapatın'),
          _buildTipItem('Uzun kayıtlar için orta kalite önerilir'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 6.h),
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getQualityDescription(ResolutionPreset preset) {
    switch (preset) {
      case ResolutionPreset.low:
        return '480p • Düşük depolama kullanımı';
      case ResolutionPreset.medium:
        return '720p • Dengeli kalite ve boyut';
      case ResolutionPreset.high:
        return '1080p • Yüksek kalite';
      case ResolutionPreset.veryHigh:
        return '1440p • Çok yüksek kalite';
      case ResolutionPreset.ultraHigh:
        return '2160p • Ultra yüksek kalite';
      case ResolutionPreset.max:
        return 'Maksimum • En yüksek kalite';
      default:
        return '';
    }
  }
}