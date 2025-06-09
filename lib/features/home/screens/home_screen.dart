import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hand_speak/features/home/widgets/profile_tab.dart';
import 'package:hand_speak/features/home/widgets/webtranslate.dart';
import 'package:hand_speak/features/home/widgets/learn_tab.dart';
import 'package:hand_speak/core/utils/translation_helper.dart' show T;
import 'package:hand_speak/providers/language_provider.dart';
import 'package:hand_speak/providers/navigation_provider.dart';
import 'dart:math' as math;
import 'dart:ui';

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
              Icon(Icons.exit_to_app, color: Colors.white, size: 20.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  T(context, 'common.exit_app_message'),
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.black87,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          margin: EdgeInsets.all(20.w),
          duration: const Duration(seconds: 2),
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
          ],
        ),
        bottomNavigationBar: Container(
          height: 56.0, // Sabit yükseklik
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[900]
                : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(3, (index) {
              final isSelected = currentIndex == index;
              return Expanded(
                child: InkWell(
                  onTap: () {
                    ref.read(navigationTabProvider.notifier).setTab(index);
                  },
                  child: Container(
                    height: 56.0,
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected 
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : Colors.transparent,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getIconForIndex(index),
                              size: 20.sp,
                              color: isSelected 
                                ? Theme.of(context).primaryColor 
                                : Colors.grey[600],
                            ),
                            if (isSelected) ...[
                              SizedBox(width: 4.w),
                              Text(
                                _getLabelForIndex(context, index),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
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