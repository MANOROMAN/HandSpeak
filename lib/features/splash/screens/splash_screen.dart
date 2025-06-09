import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _backgroundController;
  late AnimationController _handController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _handAnimation;

  double _progress = 0.0;
  String _currentStep = 'Animasyonlar başlatılıyor...';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Animation controllers
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    _handController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_backgroundController);

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeInOut,
    ));

    _handAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _handController,
      curve: Curves.easeInOut,
    ));

    // Event listeners
    _mainController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _checkAuthAndNavigate();
      }
    });

    _mainController.addListener(() {
      if (mounted) {
        setState(() {
          _progress = _mainController.value;
          _currentStep = _getProgressMessage(_progress);
        });
      }
    });

    // Start animations
    _startAnimations();
  }

  String _getProgressMessage(double progress) {
    if (progress < 0.2) return 'Uygulama başlatılıyor...';
    if (progress < 0.4) return 'Animasyonlar yükleniyor...';
    if (progress < 0.6) return 'Firebase bağlantısı kontrol ediliyor...';
    if (progress < 0.8) return 'Kullanıcı bilgileri kontrol ediliyor...';
    return 'Hazırlanıyor...';
  }

  void _startAnimations() async {
    _backgroundController.repeat();
    _handController.repeat();
    
    await Future.delayed(const Duration(milliseconds: 300));
    _scaleController.forward();
    
    await Future.delayed(const Duration(milliseconds: 500));
    _fadeController.forward();
    
    await Future.delayed(const Duration(milliseconds: 700));
    _slideController.forward();
    
    _mainController.forward();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      if (mounted) {
        context.go('/');
      }
    } else {
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _backgroundController.dispose();
    _handController.dispose();
    super.dispose();
  }

  Widget _buildCustomHandAnimation() {
    return AnimatedBuilder(
      animation: Listenable.merge([_handController, _scaleController]),
      builder: (context, child) {
        return Container(
          height: 200.h,
          width: 200.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.8),
                Colors.white.withOpacity(0.6),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer animated ring
              Transform.scale(
                scale: 1.0 + (0.3 * math.sin(_handController.value * 2 * math.pi)),
                child: Container(
                  width: 160.w,
                  height: 160.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF667eea).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                ),
              ),
              
              // Central hand icon with rotation
              Transform.rotate(
                angle: _handController.value * 0.5 * math.pi,
                child: Transform.scale(
                  scale: 1.0 + (0.1 * math.sin(_handController.value * 4 * math.pi)),
                  child: Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF667eea),
                          const Color(0xFF764ba2),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF667eea).withOpacity(0.4),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.sign_language,
                      size: 40.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF667eea),
              const Color(0xFF764ba2),
              const Color(0xFF6B73FF),
              const Color(0xFF000DFF),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo container
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      padding: EdgeInsets.all(30.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.r),
                        color: Colors.white.withOpacity(0.1),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: _buildCustomHandAnimation(),
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // App title
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          Text(
                            'HandSpeak',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 36.sp,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.0,
                            ),
                          ),

                          SizedBox(height: 12.h),

                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.r),
                              color: Colors.white.withOpacity(0.15),
                            ),
                            child: Text(
                              'Sign Language Translation App',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          SizedBox(height: 60.h),

                          // Progress bar
                          Container(
                            width: 250.w,
                            height: 6.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3.r),
                              color: Colors.white.withOpacity(0.2),
                            ),
                            child: AnimatedBuilder(
                              animation: _progressAnimation,
                              builder: (context, child) {
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: 250.w * _progressAnimation.value,
                                    height: 6.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3.r),
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          SizedBox(height: 20.h),

                          Text(
                            '${(_progress * 100).toInt()}% - $_currentStep',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
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
          ],
        ),
      ),
    );
  }
}