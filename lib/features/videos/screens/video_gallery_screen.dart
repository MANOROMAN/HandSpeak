import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hand_speak/services/video_service.dart';
import 'package:hand_speak/core/utils/translation_helper.dart' show T;
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:hand_speak/providers/navigation_provider.dart';
import 'package:hand_speak/features/settings/screens/video_quality_screen.dart';

// Providers
final savedVideosProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final videoService = VideoService();
  return await videoService.getUserVideos();
});

final viewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.grid);
enum ViewMode { grid, list }

class UnifiedVideoScreen extends ConsumerStatefulWidget {
  final Function(String)? onVideoSelected;
  final bool isSelectionMode;
  
  const UnifiedVideoScreen({
    Key? key,
    this.onVideoSelected,
    this.isSelectionMode = false,
  }) : super(key: key);

  @override
  ConsumerState<UnifiedVideoScreen> createState() => _UnifiedVideoScreenState();
}

class _UnifiedVideoScreenState extends ConsumerState<UnifiedVideoScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ImagePicker _picker = ImagePicker();
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickVideoFromDevice() async {
    try {
      final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
      if (pickedFile != null && widget.onVideoSelected != null) {
        Navigator.of(context).pop();
        widget.onVideoSelected!(pickedFile.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(T(context, 'error_picking_video')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _playVideo(String videoUrl) async {
    try {
      final Uri url = Uri.parse(videoUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch video';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(T(context, 'video_play_error')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteVideo(String videoId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8.w),
            Text(T(context, 'delete_video_title')),
          ],
        ),
        content: Text(T(context, 'delete_video_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(T(context, 'cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(T(context, 'delete')),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        final videoService = VideoService();
        await videoService.deleteVideo(videoId);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(T(context, 'video_deleted')),
              backgroundColor: Colors.green,
            ),
          );
        }
        
        ref.invalidate(savedVideosProvider);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(T(context, 'delete_error')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final videosAsync = ref.watch(savedVideosProvider);
    final viewMode = ref.watch(viewModeProvider);
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          SliverAppBar(
            expandedHeight: 200.h,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: Theme.of(context).primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.isSelectionMode 
                  ? T(context, 'select_video')
                  : T(context, 'myVideosTitle'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Container(
                        width: 200.w,
                        height: 200.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -30,
                      bottom: -30,
                      child: Container(
                        width: 150.w,
                        height: 150.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Center(
                      child: Icon(
                        Icons.video_library_rounded,
                        size: 80.sp,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  viewMode == ViewMode.grid ? Icons.list : Icons.grid_view,
                  color: Colors.white,
                ),
                onPressed: () {
                  ref.read(viewModeProvider.notifier).state = 
                    viewMode == ViewMode.grid ? ViewMode.list : ViewMode.grid;
                },
                tooltip: T(context, 'change_view'),
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () => _showVideoSettings(context),
                tooltip: T(context, 'settings'),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () => ref.invalidate(savedVideosProvider),
                tooltip: T(context, 'refresh'),
              ),
            ],
          ),
          
          // Quick Actions
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      icon: Icons.phone_android,
                      title: T(context, 'from_device'),
                      subtitle: T(context, 'select_from_gallery'),
                      color: Colors.blue,
                      onTap: _pickVideoFromDevice,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      icon: Icons.videocam,
                      title: T(context, 'record_new'),
                      subtitle: T(context, 'go_to_camera'),
                      color: Colors.green,
                      onTap: () {
                        if (!widget.isSelectionMode) {
                          ref.read(navigationTabProvider.notifier).goToTranslationTab();
                          context.go('/');
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Videos Content
          videosAsync.when(
            data: (videos) {
              if (videos.isEmpty) {
                return SliverFillRemaining(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildEmptyState(context),
                  ),
                );
              }
              
              return viewMode == ViewMode.grid
                  ? _buildGridView(videos)
                  : _buildListView(videos);
            },
            loading: () => SliverFillRemaining(
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
                      T(context, 'loading_videos'),
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            error: (error, stack) => SliverFillRemaining(
              child: _buildErrorState(error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.8),
              color,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 32.sp),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.withOpacity(0.1),
            ),
            child: Icon(
              Icons.video_library_outlined,
              size: 80.sp,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            T(context, 'no_videos_yet'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            T(context, 'record_first_video'),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.h),
          FilledButton.icon(
            onPressed: () {
              if (!widget.isSelectionMode) {
                ref.read(navigationTabProvider.notifier).goToTranslationTab();
                context.go('/');
              }
            },
            icon: const Icon(Icons.videocam),
            label: Text(T(context, 'start_recording')),
            style: FilledButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<Map<String, dynamic>> videos) {
    return SliverPadding(
      padding: EdgeInsets.all(16.w),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.w,
          childAspectRatio: 0.75,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => FadeTransition(
            opacity: _fadeAnimation,
            child: _buildVideoCard(videos[index], isGrid: true),
          ),
          childCount: videos.length,
        ),
      ),
    );
  }

  Widget _buildListView(List<Map<String, dynamic>> videos) {
    return SliverPadding(
      padding: EdgeInsets.all(16.w),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _buildVideoCard(videos[index], isGrid: false),
            ),
          ),
          childCount: videos.length,
        ),
      ),
    );
  }

  Widget _buildVideoCard(Map<String, dynamic> video, {required bool isGrid}) {
    final uploadedAt = video['uploadedAt']?.toDate() ?? DateTime.now();
    final downloadUrl = video['downloadUrl'] as String?;
    final fileName = video['fileName'] as String? ?? 'Unknown';
    final size = video['size'] as int?;
    
    if (isGrid) {
      return Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: () {
            if (widget.onVideoSelected != null && downloadUrl != null) {
              Navigator.of(context).pop();
              widget.onVideoSelected!(downloadUrl);
            } else {
              _showVideoOptions(video);
            }
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.05),
                  Theme.of(context).primaryColor.withOpacity(0.1),
                ],
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.r),
                        topRight: Radius.circular(16.r),
                      ),
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.video_library,
                          size: 40.sp,
                          color: Theme.of(context).primaryColor.withOpacity(0.3),
                        ),
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).primaryColor,
                          ),
                          child: Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          fileName.split('_').last.split('.').first,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 12.sp, color: Colors.grey),
                            SizedBox(width: 4.w),
                            Text(
                              '${uploadedAt.day}/${uploadedAt.month}/${uploadedAt.year}',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                        if (size != null) ...[
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Icon(Icons.storage, size: 12.sp, color: Colors.grey),
                              SizedBox(width: 4.w),
                              Text(
                                '${(size / (1024 * 1024)).toStringAsFixed(1)} MB',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11.sp,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    // List view card
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: () {
          if (widget.onVideoSelected != null && downloadUrl != null) {
            Navigator.of(context).pop();
            widget.onVideoSelected!(downloadUrl);
          } else {
            _showVideoOptions(video);
          }
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.1),
                      Theme.of(context).primaryColor.withOpacity(0.2),
                    ],
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.video_library,
                      size: 30.sp,
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor,
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName.split('_').last.split('.').first,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14.sp, color: Colors.grey),
                        SizedBox(width: 4.w),
                        Text(
                          '${uploadedAt.day}/${uploadedAt.month}/${uploadedAt.year} ${uploadedAt.hour}:${uploadedAt.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                    if (size != null) ...[
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Icon(Icons.storage, size: 14.sp, color: Colors.grey),
                          SizedBox(width: 4.w),
                          Text(
                            '${(size / (1024 * 1024)).toStringAsFixed(1)} MB',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showVideoOptions(video),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVideoOptions(Map<String, dynamic> video) {
    final downloadUrl = video['downloadUrl'] as String?;
    
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: const Icon(Icons.play_arrow, color: Colors.blue),
              ),
              title: Text(T(context, 'play_video')),
              onTap: () {
                Navigator.pop(context);
                if (downloadUrl != null) {
                  _playVideo(downloadUrl);
                }
              },
            ),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: const Icon(Icons.share, color: Colors.orange),
              ),
              title: Text(T(context, 'share_video')),
              onTap: () {
                Navigator.pop(context);
                // Implement share functionality
              },
            ),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: const Icon(Icons.delete, color: Colors.red),
              ),
              title: Text(
                T(context, 'delete_video'),
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteVideo(video['id']);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withOpacity(0.1),
            ),
            child: Icon(
              Icons.error_outline,
              size: 80.sp,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            T(context, 'error_loading_videos'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.red[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 32.h),
          FilledButton.icon(
            onPressed: () => ref.invalidate(savedVideosProvider),
            icon: const Icon(Icons.refresh),
            label: Text(T(context, 'try_again')),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
          ),
        ],
      ),
    );
  }

  void _showVideoSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const VideoSettingsBottomSheet(),
        fullscreenDialog: true,
      ),
    );
  }
}