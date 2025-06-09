// filepath: lib/features/learn/screens/quiz_category_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hand_speak/core/utils/translation_helper.dart' show T;
import 'package:hand_speak/models/quiz_category_model.dart';
import 'package:hand_speak/providers/sign_language_provider.dart';
import 'package:hand_speak/features/learn/models/sign_language_video.dart';
import 'dart:math' as math;

class QuizCategoryScreen extends ConsumerStatefulWidget {
  const QuizCategoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<QuizCategoryScreen> createState() => _QuizCategoryScreenState();
}

class _QuizCategoryScreenState extends ConsumerState<QuizCategoryScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _cardController;
  late AnimationController _fabController;
  late Animation<double> _headerAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _fabAnimation;
  
  int? _expandedCategoryIndex;
  bool _showLanguageDetails = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOut,
    );

    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    );
    
    _headerController.forward();
    _cardController.forward();
    _fabController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _cardController.dispose();
    _fabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<QuizCategory> get _filteredCategories {
    if (_searchQuery.isEmpty) {
      return quizCategories;
    }    return quizCategories.where((category) =>
        category.nameKey.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        category.descriptionKey.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (category.skills?.any((skill) => skill.toLowerCase().contains(_searchQuery.toLowerCase())) ?? false)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final signLanguageType = ref.watch(signLanguageProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    final safePadding = MediaQuery.of(context).padding;
    final filteredCategories = _filteredCategories;
    
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF0D1117)
          : const Color(0xFFF8FAFC),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          onPressed: () => _showQuickStartDialog(),
          backgroundColor: const Color(0xFF667EEA),
          icon: const Icon(Icons.flash_on_rounded, color: Colors.white),
          label: Text(
            'Hızlı Test',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Ultra Modern App Bar
          SliverAppBar(
            expandedHeight: math.min(280.h, screenHeight * 0.4),
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
            ),
            actions: [
              Container(
                margin: EdgeInsets.only(right: 16.w),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            _showLanguageDetails = !_showLanguageDetails;
                          });
                        },
                        icon: Icon(
                          _showLanguageDetails ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: IconButton(
                        onPressed: () => _showStatsDialog(),
                        icon: Icon(
                          Icons.analytics_rounded,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Dynamic Gradient Background
                  AnimatedBuilder(
                    animation: _headerAnimation,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF667EEA),
                              const Color(0xFF764BA2),
                              const Color(0xFF8B5CF6),
                              const Color(0xFF6366F1),
                            ],
                            stops: [
                              0.0,
                              0.3 + (_headerAnimation.value * 0.2),
                              0.7 + (_headerAnimation.value * 0.1),
                              1.0,
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Animated Floating Elements
                  ...List.generate(6, (index) {
                    return AnimatedBuilder(
                      animation: _headerAnimation,
                      builder: (context, child) {
                        final offset = _headerAnimation.value * 2 * math.pi;
                        return Positioned(
                          left: 30.0 + (index * 60) + math.sin(offset + index) * 20,
                          top: 50.0 + (index * 25) + math.cos(offset + index) * 15,
                          child: Transform.rotate(
                            angle: offset + (index * 0.5),
                            child: Container(
                              width: 35.w + (index * 5),
                              height: 35.w + (index * 5),
                              decoration: BoxDecoration(
                                shape: [BoxShape.circle, BoxShape.rectangle][(index % 2)],
                                borderRadius: index.isOdd ? BorderRadius.circular(8.r) : null,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                  
                  // Header Content
                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 20.h),
                          
                          // Quiz Icon with Pulsing Animation
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                                CurvedAnimation(parent: _headerController, curve: Curves.elasticOut)
                              ),
                              child: Container(
                                padding: EdgeInsets.all(24.w),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 25,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.quiz_rounded,
                                  size: 48.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          
                          // Animated Title
                          FadeTransition(
                            opacity: _headerAnimation,
                            child: Text(
                              'Test & Pratik',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          
                          // Subtitle with Typewriter Effect
                          Text(
                            'Bilginizi sınayın ve becerilerinizi geliştirin',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16.h),
                          
                          // Enhanced Language Indicator
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 10.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(25.r),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 28.w,
                                  height: 28.w,
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
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      signLanguageType == SignLanguageType.turkish 
                                        ? 'Türk İşaret Dili' 
                                        : 'American Sign Language',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      signLanguageType == SignLanguageType.turkish ? 'TİD' : 'ASL',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12.sp,
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
                ],
              ),
            ),
          ),
          
          // Categories Section
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, safePadding.bottom + 100.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enhanced Header with Search
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quiz Kategorileri',
                              style: TextStyle(
                                fontSize: 26.sp,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : const Color(0xFF1F2937),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '${filteredCategories.length} kategori • ${_getTotalQuestions()} soru',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                          ),
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF667EEA).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          'YENİ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  
                  // Search Bar
                  Container(
                    margin: EdgeInsets.only(bottom: 24.h),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black.withOpacity(0.3)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Kategori ara...',
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: Colors.grey[500],
                          size: 20.sp,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                                icon: Icon(
                                  Icons.clear_rounded,
                                  color: Colors.grey[500],
                                  size: 20.sp,
                                ),
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 16.h,
                        ),
                      ),
                    ),
                  ),
                  
                  // Categories List with Enhanced Animation
                  if (filteredCategories.isEmpty) ...[
                    _buildNoResultsView(),
                  ] else ...[
                    ...List.generate(filteredCategories.length, (index) {
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 600 + (index * 100)),
                        curve: Curves.easeOutBack,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 50 * (1 - value)),
                            child: Opacity(
                              opacity: value,
                              child: _buildUltraModernCategoryCard(
                                context, 
                                filteredCategories[index], 
                                index,
                                signLanguageType,
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickStartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(Icons.flash_on_rounded, color: Colors.amber, size: 24.sp),
            SizedBox(width: 8.w),
            const Text('Hızlı Test'),
          ],
        ),
        content: const Text('Bu özellik henüz geliştirme aşamasındadır.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showStatsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(Icons.bar_chart_rounded, color: Colors.blue, size: 24.sp),
            SizedBox(width: 8.w),
            const Text('Test İstatistikleri'),
          ],
        ),
        content: const Text('Bu özellik henüz geliştirme aşamasındadır.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            'Aradığınız kritere uygun kategori bulunamadı',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'Farklı bir arama terimi deneyin',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUltraModernCategoryCard(QuizCategory category, int index) {
    final isExpanded = _expandedCategoryIndex == index;
    final signLanguageType = ref.watch(signLanguageProvider);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            category.color.withOpacity(0.1),
            category.color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: category.color.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: isExpanded ? [
          BoxShadow(
            color: category.color.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          )
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _expandedCategoryIndex = isExpanded ? null : index),
          borderRadius: BorderRadius.circular(24.r),
          child: Container(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Hero(
                      tag: 'category_${category.id}',
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              category.color,
                              category.color.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: category.color.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          category.icon,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.nameKey,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: category.color,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            category.descriptionKey,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: category.color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: category.color,
                        size: 20.sp,
                      ),
                    ),
                  ],
                ),
                
                // Expanded Content
                AnimatedCrossFade(
                  firstChild: const SizedBox(height: 0),
                  secondChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.h),
                      Divider(color: category.color.withOpacity(0.1), thickness: 2),
                      SizedBox(height: 16.h),
                      
                      // Quiz Stats
                      Row(
                        children: [
                          _buildInfoTag(
                            icon: Icons.quiz_rounded,
                            label: '${category.estimatedQuestions ?? 0} Soru',
                            color: category.color,
                          ),
                          SizedBox(width: 8.w),
                          _buildInfoTag(
                            icon: _getDifficultyIcon(category.difficultyLevel ?? 'medium'),
                            label: _getDifficultyText(category.difficultyLevel ?? 'medium'),
                            color: _getDifficultyColor(category.difficultyLevel ?? 'medium'),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 16.h),
                      
                      // Language Selection
                      Row(
                        children: [
                          Text(
                            'Dil:',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: signLanguageType == SignLanguageType.turkish 
                                  ? Colors.red.withOpacity(0.1) 
                                  : Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: signLanguageType == SignLanguageType.turkish 
                                    ? Colors.red.withOpacity(0.3) 
                                    : Colors.blue.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.language_rounded,
                                  size: 16.sp,
                                  color: signLanguageType == SignLanguageType.turkish 
                                      ? Colors.red : Colors.blue,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  signLanguageType == SignLanguageType.turkish ? 'TİD' : 'ASL',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: signLanguageType == SignLanguageType.turkish 
                                        ? Colors.red : Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 24.h),
                      
                      // Start Quiz Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            context.push('/learn/quiz?category=${category.id}');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: category.color,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            elevation: 4,
                          ),
                          child: Text(
                            'Teste Başla',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  crossFadeState: isExpanded 
                      ? CrossFadeState.showSecond 
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _getTotalQuestions() {
    return quizCategories.fold(
      0, 
      (sum, category) => sum + (category.estimatedQuestions ?? 0)
    );
  }
  
  Widget _buildInfoTag({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty) {
      case 'easy': return Icons.sentiment_satisfied_rounded;
      case 'medium': return Icons.sentiment_neutral_rounded;
      case 'hard': return Icons.sentiment_very_dissatisfied_rounded;
      case 'mixed': return Icons.shuffle_rounded;
      default: return Icons.help_outline_rounded;
    }
  }

  String _getDifficultyText(String difficulty) {
    switch (difficulty) {
      case 'easy': return 'Kolay';
      case 'medium': return 'Orta';
      case 'hard': return 'Zor';
      case 'mixed': return 'Karma';
      default: return 'Bilinmiyor';
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy': return const Color(0xFF10B981);
      case 'medium': return const Color(0xFFF59E0B);
      case 'hard': return const Color(0xFFEF4444);
      case 'mixed': return const Color(0xFF8B5CF6);
      default: return Colors.grey;
    }
  }