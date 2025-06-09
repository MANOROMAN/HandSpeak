import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hand_speak/features/learn/screens/video_player_screen.dart';
import 'package:hand_speak/features/learn/data/video_data.dart';
import 'package:hand_speak/features/learn/models/sign_language_video.dart';
import 'package:hand_speak/providers/sign_language_provider.dart' hide SignLanguageType;
import 'package:hand_speak/core/utils/translation_helper.dart' show T;
import 'package:cached_network_image/cached_network_image.dart';

class ModernVideoListScreen extends ConsumerStatefulWidget {
  final String categoryId;

  const ModernVideoListScreen({Key? key, required this.categoryId}) : super(key: key);

  @override
  ConsumerState<ModernVideoListScreen> createState() => _ModernVideoListScreenState();
}

class _ModernVideoListScreenState extends ConsumerState<ModernVideoListScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late ScrollController _scrollController;
  bool _isGridView = false;
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
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
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  List<SignLanguageVideo> _getVideosForCategory(SignLanguageType languageType) {
    return VideoData.getVideosForCategory(widget.categoryId, languageType);
  }

  String _getCategoryTitle(String categoryId) {
    switch (categoryId) {
      case 'alphabet':
        return T(context, 'learn.alphabet');
      case 'numbers':
        return T(context, 'learn.numbers');
      case 'common_phrases':
        return T(context, 'learn.common_phrases');
      case 'daily_words':
        return T(context, 'learn.daily_words');
      default:
        return '';
    }
  }

  Color _getCategoryColor(String categoryId) {
    switch (categoryId) {
      case 'alphabet':
        return Colors.blue.shade600;
      case 'numbers':
        return Colors.green.shade600;
      case 'common_phrases':
        return Colors.orange.shade600;
      case 'daily_words':
        return Colors.purple.shade600;
      default:
        return Colors.blue.shade600;
    }
  }

  IconData _getCategoryIcon(String categoryId) {
    switch (categoryId) {
      case 'alphabet':
        return Icons.abc_rounded;
      case 'numbers':
        return Icons.numbers_rounded;
      case 'common_phrases':
        return Icons.chat_bubble_rounded;
      case 'daily_words':
        return Icons.today_rounded;
      default:
        return Icons.play_circle_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final signLanguageType = ref.watch(signLanguageProvider);
    final videos = _getVideosForCategory(signLanguageType);
    final categoryColor = _getCategoryColor(widget.categoryId);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Modern App Bar
          SliverAppBar(
            expandedHeight: 220.h,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: categoryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _getCategoryTitle(widget.categoryId),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient Background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          categoryColor.withOpacity(0.8),
                          categoryColor,
                        ],
                      ),
                    ),
                  ),
                  // Pattern Overlay
                  Positioned(
                    right: -50,
                    top: -50,
                    child: Icon(
                      _getCategoryIcon(widget.categoryId),
                      size: 200.sp,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  // Category Info
                  Positioned(
                    bottom: 60.h,
                    left: 20.w,
                    right: 20.w,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getCategoryIcon(widget.categoryId),
                              color: Colors.white,
                              size: 32.sp,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            T(context, 'learn.${widget.categoryId}_desc'),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // View Mode Toggle
              IconButton(
                icon: Icon(
                  _isGridView ? Icons.list_rounded : Icons.grid_view_rounded,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() => _isGridView = !_isGridView);
                },
                tooltip: _isGridView ? 'Liste Görünümü' : 'Izgara Görünümü',
              ),
              // Language Toggle
              Container(
                margin: EdgeInsets.only(right: 8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: InkWell(
                  onTap: () {
                    ref.read(signLanguageProvider.notifier).toggleLanguage();
                  },
                  borderRadius: BorderRadius.circular(20.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 24.w,
                          height: 24.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage(
                                signLanguageType == SignLanguageType.turkish 
                                  ? 'assets/images/tr.png' 
                                  : 'assets/images/en.png',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          signLanguageType == SignLanguageType.turkish ? 'TR' : 'EN',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Video Count Header
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${videos.length} ${signLanguageType == SignLanguageType.turkish ? "Video" : "Videos"}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.language,
                          size: 16.sp,
                          color: categoryColor,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          signLanguageType == SignLanguageType.turkish 
                            ? 'Türk İşaret Dili' 
                            : 'American Sign Language',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: categoryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Videos Content
          if (videos.isEmpty)
            SliverFillRemaining(
              child: _buildEmptyState(signLanguageType),
            )
          else if (_isGridView)
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.w,
                  childAspectRatio: 0.75,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildGridVideoCard(videos[index], categoryColor, index),
                  childCount: videos.length,
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildListVideoCard(videos[index], categoryColor, index),
                  childCount: videos.length,
                ),
              ),
            ),
          
          // Bottom Padding
          SliverToBoxAdapter(
            child: SizedBox(height: 20.h),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(SignLanguageType languageType) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 80.sp,
            color: Colors.grey,
          ),
          SizedBox(height: 16.h),
          Text(
            languageType == SignLanguageType.turkish
              ? 'Bu kategori için henüz video eklenmemiş'
              : 'No videos available for this category yet',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridVideoCard(SignLanguageVideo video, Color categoryColor, int index) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, 0.1 + (index * 0.05)),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.1,
            1.0,
            curve: Curves.easeOutCubic,
          ),
        )),
        child: Hero(
          tag: 'video_${video.videoId}',
          child: Material(
            borderRadius: BorderRadius.circular(16.r),
            elevation: 4,
            child: InkWell(
              onTap: () => _navigateToPlayer(video),
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail
                    Expanded(
                      flex: 3,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16.r),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: video.thumbnailUrl,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: categoryColor.withOpacity(0.1),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: categoryColor.withOpacity(0.1),
                                child: Icon(
                                  Icons.video_library,
                                  color: categoryColor,
                                  size: 40.sp,
                                ),
                              ),
                            ),
                          ),
                          // Play Button Overlay
                          Center(
                            child: Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 28.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Title
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.all(12.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              video.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (video.description != null) ...[
                              SizedBox(height: 4.h),
                              Text(
                                video.description!,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
          ),
        ),
      ),
    );
  }

  Widget _buildListVideoCard(SignLanguageVideo video, Color categoryColor, int index) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0.1 + (index * 0.05), 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.1,
            1.0,
            curve: Curves.easeOutCubic,
          ),
        )),
        child: Container(
          margin: EdgeInsets.only(bottom: 12.h),
          child: Hero(
            tag: 'video_${video.videoId}',
            child: Material(
              borderRadius: BorderRadius.circular(16.r),
              elevation: 3,
              child: InkWell(
                onTap: () => _navigateToPlayer(video),
                borderRadius: BorderRadius.circular(16.r),
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  child: Row(
                    children: [
                      // Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: CachedNetworkImage(
                          imageUrl: video.thumbnailUrl,
                          width: 120.w,
                          height: 80.h,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: categoryColor.withOpacity(0.1),
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: categoryColor.withOpacity(0.1),
                            child: Icon(
                              Icons.video_library,
                              color: categoryColor,
                              size: 30.sp,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // Video Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              video.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (video.description != null) ...[
                              SizedBox(height: 4.h),
                              Text(
                                video.description!,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: categoryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.play_circle_outline,
                                        size: 14.sp,
                                        color: categoryColor,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        'Video',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: categoryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Arrow
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
          ),
        ),
      ),
    );
  }

  void _navigateToPlayer(SignLanguageVideo video) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ModernVideoPlayerScreen(
          videoId: video.videoId,
          title: video.title,
          categoryId: widget.categoryId,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }
}