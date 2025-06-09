import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hand_speak/core/utils/translation_helper.dart' show T;
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:math' as math;
import 'dart:async';
import 'dart:ui';

class ModernTranslationTab extends ConsumerStatefulWidget {
  const ModernTranslationTab({Key? key}) : super(key: key);

  @override
  ConsumerState<ModernTranslationTab> createState() => _ModernTranslationTabState();
}

class _ModernTranslationTabState extends ConsumerState<ModernTranslationTab> 
    with TickerProviderStateMixin {
  
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  late AnimationController _floatController;
  
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _floatAnimation;
  
  int _selectedResourceIndex = 0;
  final PageController _pageController = PageController(viewportFraction: 0.9);

  final List<Map<String, dynamic>> _resources = [
    {
      'title': 'Sign.mt',
      'subtitle': 'Amerikan İşaret Dili (ASL)',
      'url': 'https://sign.mt',
      'icon': Icons.sign_language_rounded,
      'color': const Color(0xFF6366F1),
      'gradient': [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
      'description': 'AI destekli ASL çeviri platformu',
      'features': [
        'ASL Çeviri',
        'Gerçek Zamanlı',
        'Yüksek Doğruluk',
        'Video Analiz'
      ],
      'stats': {
        'users': '50K+',
        'accuracy': '%95',
        'languages': 'ASL',
      }
    },
    {
      'title': 'Türk İşaret Dili',
      'subtitle': '4761+ Kelime Veritabanı',
      'url': 'https://www.turkisaretdili.net',
      'icon': Icons.menu_book_rounded,
      'color': const Color(0xFF10B981),
      'gradient': [const Color(0xFF10B981), const Color(0xFF34D399)],
      'description': 'Kapsamlı işaret dili sözlüğü ve öğrenme platformu',
      'features': [
        '4761+ Kelime',
        'Video Örnekler',
        'Detaylı Açıklamalar',
        'Kategorik Arama'
      ],
      'stats': {
        'words': '4761+',
        'videos': '5000+',
        'categories': '25+',
      }
    },
    {
      'title': 'Spread the Sign',
      'subtitle': 'Uluslararası İşaret Dili Sözlüğü',
      'url': 'https://www.spreadthesign.com/tr.tr/search/',
      'icon': Icons.language_rounded,
      'color': const Color(0xFFEC4899),
      'gradient': [const Color(0xFFEC4899), const Color(0xFFF472B6)],
      'description': 'Dünyanın en büyük işaret dili sözlüğü - 40+ dil desteği',
      'features': [
        '40+ Dil',
        'Video Sözlük',
        'Çoklu İşaret Dili',
        'Karşılaştırmalı Öğrenme'
      ],
      'stats': {
        'languages': '40+',
        'words': '200K+',
        'countries': '40+',
      }
    },
  ];



  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    
    _shimmerAnimation = Tween<double>(
      begin: -1,
      end: 2,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.linear,
    ));
    
    _floatAnimation = Tween<double>(
      begin: -5,
      end: 5,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    _shimmerController.dispose();
    _floatController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _openInWebView(String url, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WebViewScreen(
          url: url,
          title: title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).primaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),
                      
                      // Title Section
                      _buildTitleSection(),
                      
                      SizedBox(height: 30.h),
                      
                      // Resource Cards
                      _buildResourceCards(),
                      
                      SizedBox(height: 20.h),
                      
                      // Page Indicator
                      _buildPageIndicator(),
                      
                      SizedBox(height: 30.h),
                      
                      // Bottom Info
                      _buildBottomInfo(),
                      
                      SizedBox(height: 20.h),
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



  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sign_language_rounded,
            size: 24.sp,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(width: 10.w),
          Text(
            'İşaret Dili Kaynakları',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Column(
            children: [
              Text(
                'Profesyonel Çeviri Platformları',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.headlineLarge?.color,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'İşaret dili öğrenme ve çeviri kaynakları',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResourceCards() {
    return SizedBox(
      height: 400.h,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedResourceIndex = index;
          });
        },
        itemCount: _resources.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double value = 1.0;
              if (_pageController.position.haveDimensions) {
                value = _pageController.page! - index;
                value = (1 - (value.abs() * 0.15)).clamp(0.0, 1.0);
              }
              
              return Center(
                child: SizedBox(
                  height: Curves.easeOut.transform(value) * 380.h,
                  width: Curves.easeOut.transform(value) * 340.w,
                  child: _buildResourceCard(_resources[index], index == _selectedResourceIndex),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildResourceCard(Map<String, dynamic> resource, bool isSelected) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        _openInWebView(resource['url'], resource['title']);
      },
      onTapCancel: () => _scaleController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isSelected ? _scaleAnimation.value : 0.95,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: resource['gradient'],
                ),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: resource['color'].withOpacity(0.3),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Shimmer Effect
                  if (isSelected)
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _shimmerAnimation,
                        builder: (context, child) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(20.r),
                            child: Transform.translate(
                              offset: Offset(_shimmerAnimation.value * 200, 0),
                              child: Container(
                                width: 80.w,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withOpacity(0.1),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  
                  // Content
                  Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            resource['icon'],
                            size: 32.sp,
                            color: Colors.white,
                          ),
                        ),
                        
                        SizedBox(height: 16.h),
                        
                        // Title
                        Text(
                          resource['title'],
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        
                        SizedBox(height: 6.h),
                        
                        // Subtitle
                        Text(
                          resource['subtitle'],
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        
                        SizedBox(height: 12.h),
                        
                        // Description
                        Text(
                          resource['description'],
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.white.withOpacity(0.8),
                            height: 1.4,
                          ),
                        ),
                        
                        SizedBox(height: 16.h),
                        
                        // Features
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: resource['features'].map<Widget>((feature) => Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              feature,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.white,
                              ),
                            ),
                          )).toList(),
                        ),
                        
                        Spacer(),
                        
                        // Action Button
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Ziyaret Et',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 16.sp,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _resources.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: _selectedResourceIndex == index ? 30.w : 8.w,
          height: 8.h,
          decoration: BoxDecoration(
            color: _selectedResourceIndex == index
                ? _resources[index]['color']
                : Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomInfo() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            color: Theme.of(context).primaryColor,
            size: 24.sp,
          ),
          SizedBox(height: 8.h),
          Text(
            'Bu platformlar işaret dili öğrenmek ve çeviri yapmak için profesyonel kaynaklardır.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

// WebView Screen
class WebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const WebViewScreen({
    Key? key,
    required this.url,
    required this.title,
  }) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _progress = progress / 100;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Sayfa yüklenemedi: ${error.description}'),
                backgroundColor: Colors.red,
              ),
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}