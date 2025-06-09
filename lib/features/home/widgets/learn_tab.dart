import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hand_speak/core/utils/translation_helper.dart' show T;
import 'package:hand_speak/providers/sign_language_provider.dart' hide SignLanguageType; 
import 'package:hand_speak/features/learn/models/sign_language_video.dart';
import 'dart:math' as math;

class ModernLearnTab extends ConsumerStatefulWidget {
  const ModernLearnTab({Key? key}) : super(key: key);

  @override
  ConsumerState<ModernLearnTab> createState() => _ModernLearnTabState();
}

class _ModernLearnTabState extends ConsumerState<ModernLearnTab> 
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _cardController;
  late AnimationController _floatingController;
  late Animation<double> _waveAnimation;
  late Animation<double> _floatingAnimation;
  
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  
  @override
  void initState() {
    super.initState();
    
    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    
    _floatingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_waveController);
    
    _floatingAnimation = Tween<double>(
      begin: -8.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));
    
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }
  
  @override
  void dispose() {
    _waveController.dispose();
    _cardController.dispose();
    _floatingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signLanguageType = ref.watch(signLanguageProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    final safePadding = MediaQuery.of(context).padding;
    
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF0D1117)
          : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              // Animated Background
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _waveAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: WaveBackgroundPainter(
                        wavePhase: _waveAnimation.value,
                        scrollOffset: _scrollOffset,
                        color: Theme.of(context).primaryColor.withOpacity(0.02),
                      ),
                    );
                  },
                ),
              ),
              
              // Main Content
              CustomScrollView(
                controller: _scrollController,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                slivers: [
                  // Modern App Bar
                  SliverAppBar(
                    expandedHeight: math.min(240.h, screenHeight * 0.35),
                    floating: true,
                    pinned: true,
                    stretch: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        children: [
                          // Gradient Background
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF667EEA),
                                  Color(0xFF764BA2),
                                  Color(0xFF6B73FF),
                                ],
                              ),
                            ),
                          ),
                          
                          // Floating Elements
                          ...List.generate(3, (index) {
                            return AnimatedBuilder(
                              animation: _floatingAnimation,
                              builder: (context, child) {
                                return Positioned(
                                  left: 50.0 + (index * 60),
                                  top: 50.0 + (index * 20) + _floatingAnimation.value,
                                  child: Container(
                                    width: 40.w + (index * 6),
                                    height: 40.w + (index * 6),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.06),
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                          
                          // Content
                          SafeArea(
                            child: Padding(
                              padding: EdgeInsets.all(20.w),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 16.h),
                                    
                                    // Animated Icon
                                    AnimatedBuilder(
                                      animation: _floatingAnimation,
                                      builder: (context, child) {
                                        return Transform.translate(
                                          offset: Offset(0, _floatingAnimation.value / 3),
                                          child: Container(
                                            padding: EdgeInsets.all(16.w),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white.withOpacity(0.15),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.1),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 6),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.sign_language_rounded,
                                              size: 32.sp,
                                              color: Colors.white,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(height: 16.h),
                                    
                                    // Title
                                    Text(
                                      T(context, 'learn.title'),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24.sp,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                    SizedBox(height: 6.h),
                                    
                                    // Subtitle
                                    Text(
                                      T(context, 'learn.description'),
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 14.sp,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    
                                    SizedBox(height: 16.h),
                                    
                                    // Language Selector
                                    GestureDetector(
                                      onTap: () {
                                        ref.read(signLanguageProvider.notifier).toggleLanguage();
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16.w,
                                          vertical: 8.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(20.r),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.2),
                                            width: 1.5,
                                          ),
                                        ),
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
                                            SizedBox(width: 8.w),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  signLanguageType == SignLanguageType.turkish 
                                                    ? 'Türk İşaret Dili' 
                                                    : 'American Sign Language',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12.sp,
                                                  ),
                                                ),
                                                Text(
                                                  'Dili değiştir',
                                                  style: TextStyle(
                                                    color: Colors.white.withOpacity(0.7),
                                                    fontSize: 10.sp,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(width: 6.w),
                                            Icon(
                                              Icons.swap_horiz_rounded,
                                              color: Colors.white,
                                              size: 16.sp,
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
                        ],
                      ),
                    ),
                  ),
                  
                  // Categories Section with proper constraints
                  SliverToBoxAdapter(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: screenHeight * 0.65 - safePadding.bottom - 80.h, // Account for tab bar
                      ),
                      child: Container(
                        padding: EdgeInsets.fromLTRB(
                          20.w, 
                          16.h, 
                          20.w, 
                          safePadding.bottom + 80.h // Tab bar + extra space
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Öğrenmeye Başla',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : const Color(0xFF1F2937),
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              'İhtiyacınıza göre bir kategori seçin',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 16.h),
                            
                            // Category Grid
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 14.w,
                                mainAxisSpacing: 14.h,
                                childAspectRatio: 0.9,
                              ),
                              itemCount: 6,
                              itemBuilder: (context, index) {
                                return TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: Duration(milliseconds: 400 + (index * 80)),
                                  curve: Curves.easeOutBack,
                                  builder: (context, value, child) {
                                    return Transform.scale(
                                      scale: value,
                                      child: Opacity(
                                        opacity: value,
                                        child: _buildCompactCard(
                                          context,
                                          _getCategoryData()[index],
                                          index,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildCompactCard(BuildContext context, Map<String, dynamic> category, int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(category['route']),
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: (category['color'] as Color).withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18.r),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      (category['color'] as Color).withOpacity(0.9),
                      (category['color'] as Color),
                    ],
                  ),
                ),
              ),
              
              // Glass Effect
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18.r),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
              
              // Decorative Circle
              Positioned(
                right: -15,
                bottom: -15,
                child: Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              
              // Content
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            category['icon'] as IconData,
                            size: 24.sp,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          category['title'] as String,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          category['description'] as String,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                    
                    // Progress or Action
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (index < 4) ...[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'İlerleme',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 9.sp,
                                  ),
                                ),
                                SizedBox(height: 3.h),
                                Container(
                                  height: 2.5.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(2.r),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: 0.3 + (index * 0.2),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(2.r),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
                        ],
                        Container(
                          padding: EdgeInsets.all(5.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  List<Map<String, dynamic>> _getCategoryData() {
    return [
      {
        'id': 'alphabet',
        'title': 'Alfabe',
        'description': 'A-Z harflerini öğrenin',
        'icon': Icons.abc_rounded,
        'color': const Color(0xFF6366F1),
        'route': '/learn/alphabet',
      },
      {
        'id': 'numbers',
        'title': 'Sayılar',
        'description': '0-100 arası sayılar',
        'icon': Icons.numbers_rounded,
        'color': const Color(0xFF10B981),
        'route': '/learn/numbers',
      },
      {
        'id': 'phrases',
        'title': 'Yaygın İfadeler',
        'description': 'Günlük konuşmalar',
        'icon': Icons.chat_bubble_rounded,
        'color': const Color(0xFFF59E0B),
        'route': '/learn/phrases',
      },
      {
        'id': 'daily_words',
        'title': 'Günlük Kelimeler',
        'description': 'Temel kelime hazinesi',
        'icon': Icons.today_rounded,
        'color': const Color(0xFFEF4444),
        'route': '/learn/daily-words',
      },
      {
        'id': 'research',
        'title': 'Araştırma',
        'description': 'Gelişmiş kaynaklar',
        'icon': Icons.language_rounded,
        'color': const Color(0xFF06B6D4),
        'route': '/learn/research',
      },
      {
        'id': 'quiz',
        'title': 'Test & Pratik',
        'description': 'Bilginizi sınayın',
        'icon': Icons.quiz_rounded,
        'color': const Color(0xFF8B5CF6),
        'route': '/learn/quiz-categories',
      },
    ];
  }
}

// Optimized Wave Background Painter
class WaveBackgroundPainter extends CustomPainter {
  final double wavePhase;
  final double scrollOffset;
  final Color color;
  
  WaveBackgroundPainter({
    required this.wavePhase,
    required this.scrollOffset,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final path = Path();
    
    // Simplified wave with fewer calculations
    final waveHeight = 30.0;
    final yOffset = size.height * 0.8 - (scrollOffset * 0.05);
    
    path.moveTo(0, yOffset);
    
    for (double x = 0; x <= size.width; x += 10) {
      final y = yOffset + math.sin((x / size.width * 2 * math.pi) + wavePhase) * waveHeight;
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}