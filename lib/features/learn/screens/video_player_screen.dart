import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:hand_speak/providers/sign_language_provider.dart';
import 'package:hand_speak/features/learn/models/sign_language_video.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ModernVideoPlayerScreen extends ConsumerStatefulWidget {
  final String videoId;
  final String title;
  final String? categoryId;
  
  const ModernVideoPlayerScreen({
    Key? key,
    required this.videoId,
    required this.title,
    this.categoryId,
  }) : super(key: key);

  @override
  ConsumerState<ModernVideoPlayerScreen> createState() => _ModernVideoPlayerScreenState();
}

class _ModernVideoPlayerScreenState extends ConsumerState<ModernVideoPlayerScreen> 
    with SingleTickerProviderStateMixin {
  late YoutubePlayerController _controller;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool isLoading = false;
  bool _isFullScreen = false;
  double _playbackSpeed = 1.0;
  
  String get youtubeUrl => 'https://www.youtube.com/watch?v=${widget.videoId}';
  bool get isTurkishLanguage => ref.watch(signLanguageProvider) == SignLanguageType.turkish;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
        captionLanguage: 'auto',
        showLiveFullscreenButton: true,
        disableDragSeek: false,
        loop: false,
        forceHD: true,
        hideThumbnail: false,
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _launchVideo() async {
    setState(() => isLoading = true);
    try {
      final Uri url = Uri.parse(youtubeUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          message: isTurkishLanguage 
            ? 'Video açılırken hata oluştu' 
            : 'Error opening video',
          isError: true,
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnackBar({required String message, bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: Colors.white,
            ),
            SizedBox(width: 8.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
        progressColors: const ProgressBarColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
          bufferedColor: Colors.red,
          backgroundColor: Colors.grey,
        ),
      ),
      builder: (context, player) => Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              // Video Player
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                color: Colors.black,
                child: Center(child: player),
              ),
              
              // Gradient Overlay
              if (!_isFullScreen)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 100.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              
              // Top Controls
              if (!_isFullScreen)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          Expanded(
                            child: Text(
                              widget.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildSpeedControl(),
                          IconButton(
                            icon: const Icon(Icons.open_in_new, color: Colors.white),
                            onPressed: _launchVideo,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              
              // Bottom Info Panel
              if (!_isFullScreen)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(_fadeAnimation),
                    child: _buildBottomPanel(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedControl() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: PopupMenuButton<double>(
        initialValue: _playbackSpeed,
        onSelected: (speed) {
          setState(() => _playbackSpeed = speed);
          _controller.setPlaybackRate(speed);
        },
        itemBuilder: (context) => [
          for (final speed in [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0])
            PopupMenuItem(
              value: speed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${speed}x'),
                  if (speed == _playbackSpeed)
                    Icon(Icons.check, size: 16.sp, color: Theme.of(context).primaryColor),
                ],
              ),
            ),
        ],
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.speed, color: Colors.white, size: 16.sp),
            SizedBox(width: 4.w),
            Text(
              '${_playbackSpeed}x',
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.white, size: 16.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(top: 12.h),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          
          // Control Buttons
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  icon: Icons.replay_10,
                  label: '-10s',
                  onPressed: () {
                    _controller.seekTo(Duration(
                      seconds: _controller.value.position.inSeconds - 10,
                    ));
                  },
                ),
                _buildControlButton(
                  icon: _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  label: _controller.value.isPlaying 
                    ? (isTurkishLanguage ? 'Duraklat' : 'Pause')
                    : (isTurkishLanguage ? 'Oynat' : 'Play'),
                  isPrimary: true,
                  onPressed: () {
                    setState(() {
                      _controller.value.isPlaying 
                        ? _controller.pause() 
                        : _controller.play();
                    });
                  },
                ),
                _buildControlButton(
                  icon: Icons.forward_10,
                  label: '+10s',
                  onPressed: () {
                    _controller.seekTo(Duration(
                      seconds: _controller.value.position.inSeconds + 10,
                    ));
                  },
                ),
              ],
            ),
          ),
          
          // Learning Tips
          Container(
            margin: EdgeInsets.all(16.w),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.1),
                  Theme.of(context).primaryColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lightbulb_outline,
                        color: Theme.of(context).primaryColor,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      isTurkishLanguage ? 'Öğrenme İpuçları' : 'Learning Tips',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                _buildTip(
                  icon: Icons.slow_motion_video,
                  text: isTurkishLanguage 
                    ? 'Hareketleri daha iyi öğrenmek için videoyu yavaşlatın'
                    : 'Slow down the video to learn movements better',
                ),
                _buildTip(
                  icon: Icons.replay,
                  text: isTurkishLanguage 
                    ? 'Zor kısımları tekrar tekrar izleyin'
                    : 'Replay difficult parts repeatedly',
                ),
                _buildTip(
                  icon: Icons.front_hand,
                  text: isTurkishLanguage 
                    ? 'Videoyla birlikte pratik yapmayı unutmayın'
                    : 'Don\'t forget to practice along with the video',
                ),
              ],
            ),
          ),
          
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return Material(
      color: isPrimary 
        ? Theme.of(context).primaryColor 
        : Theme.of(context).primaryColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isPrimary ? Colors.white : Theme.of(context).primaryColor,
                size: 24.sp,
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary ? Colors.white : Theme.of(context).primaryColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTip({required IconData icon, required String text}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16.sp, color: Theme.of(context).primaryColor),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14.sp, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}