import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hand_speak/features/home/widgets/profile_tab.dart';
import 'package:hand_speak/features/home/widgets/translation_tab.dart';
import 'package:hand_speak/features/home/widgets/learn_tab.dart';
import 'package:hand_speak/core/utils/translation_helper.dart' show T;
import 'package:hand_speak/providers/language_provider.dart';
import 'package:hand_speak/providers/navigation_provider.dart';
import 'dart:math' as math;

class ModernHomeScreen extends ConsumerStatefulWidget {
  const ModernHomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ModernHomeScreen> createState() => _ModernHomeScreenState();
}

class _ModernHomeScreenState extends ConsumerState<ModernHomeScreen> 
    with TickerProviderStateMixin {
  late AnimationController _navigationAnimationController;
  late AnimationController _floatingButtonController;
  late Animation<double> _floatingButtonAnimation;
  late List<Animation<double>> _iconAnimations;
  
  DateTime? _lastBackPressTime;
  
  List<Widget> get _pages => [
    const ModernTranslationTab(),
    const ModernLearnTab(),
    const UltraModernProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    
    _navigationAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _floatingButtonController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _floatingButtonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingButtonController,
      curve: Curves.elasticOut,
    ));
    
    _iconAnimations = List.generate(
      3,
      (index) => Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _navigationAnimationController,
          curve: Interval(
            index * 0.1,
            0.5 + index * 0.1,
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );
    
    _navigationAnimationController.forward();
    _floatingButtonController.forward();
  }

  @override
  void dispose() {
    _navigationAnimationController.dispose();
    _floatingButtonController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (_lastBackPressTime == null || 
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      
      // Modern snackbar with animation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.exit_to_app, color: Colors.white),
              SizedBox(width: 12.w),
              Text(T(context, 'common.exit_app_message')),
            ],
          ),
          backgroundColor: Colors.black87,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          margin: EdgeInsets.all(20.w),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(languageProvider);
    final currentIndex = ref.watch(navigationTabProvider);
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        extendBody: true,
        body: Stack(
          children: [
            // Background Gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor,
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
                    Theme.of(context).primaryColor.withOpacity(0.05),
                  ],
                ),
              ),
            ),
            
            // Page Content
            IndexedStack(
              index: currentIndex,
              children: _pages,
            ),
            
            // Floating Action Button
            if (currentIndex == 0) // Show only on translation tab
              Positioned(
                bottom: 100.h,
                right: 20.w,
                child: ScaleTransition(
                  scale: _floatingButtonAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.8),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: FloatingActionButton(
                      onPressed: () {
                        // Quick action
                      },
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      child: Icon(
                        Icons.mic,
                        color: Colors.white,
                        size: 28.sp,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: Container(
          height: 90.h,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.r),
              topRight: Radius.circular(30.r),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.r),
              topRight: Radius.circular(30.r),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(3, (index) {
                  final isSelected = currentIndex == index;
                  return Expanded(
                    child: InkWell(
                      onTap: () {
                        ref.read(navigationTabProvider.notifier).setTab(index);
                        _navigationAnimationController.reset();
                        _navigationAnimationController.forward();
                      },
                      child: AnimatedBuilder(
                        animation: _iconAnimations[index],
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 0.8 + (_iconAnimations[index].value * 0.2),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Background circle
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        width: isSelected ? 50.w : 0,
                                        height: isSelected ? 50.w : 0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: [
                                              Theme.of(context).primaryColor.withOpacity(0.2),
                                              Theme.of(context).primaryColor.withOpacity(0.1),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Icon
                                      Icon(
                                        _getIconForIndex(index),
                                        size: isSelected ? 28.sp : 24.sp,
                                        color: isSelected 
                                          ? Theme.of(context).primaryColor 
                                          : Colors.grey,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4.h),
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 300),
                                    style: TextStyle(
                                      fontSize: isSelected ? 12.sp : 10.sp,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected 
                                        ? Theme.of(context).primaryColor 
                                        : Colors.grey,
                                    ),
                                    child: Text(_getLabelForIndex(context, index)),
                                  ),
                                  // Selection indicator
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: EdgeInsets.only(top: 4.h),
                                    width: isSelected ? 20.w : 0,
                                    height: 3.h,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(2.r),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.translate_rounded;
      case 1:
        return Icons.school_rounded;
      case 2:
        return Icons.person_rounded;
      default:
        return Icons.home_rounded;
    }
  }
  
  String _getLabelForIndex(BuildContext context, int index) {
    switch (index) {
      case 0:
        return T(context, 'home.translation');
      case 1:
        return T(context, 'home.learn');
      case 2:
        return T(context, 'home.profile');
      default:
        return '';
    }
  }
}