import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hand_speak/providers/user_provider.dart';
import 'package:hand_speak/providers/settings_provider.dart';
import 'package:hand_speak/models/user_model.dart';
import 'package:hand_speak/widgets/profile_photo_upload_widget.dart';
import 'package:intl/intl.dart';
import 'package:hand_speak/core/utils/translation_helper.dart' show T;
import 'package:hand_speak/core/theme/app_theme.dart';
import 'dart:math' as math;

class UltraModernProfileTab extends ConsumerStatefulWidget {
  const UltraModernProfileTab({super.key});

  @override
  ConsumerState<UltraModernProfileTab> createState() => _UltraModernProfileTabState();
}

class _UltraModernProfileTabState extends ConsumerState<UltraModernProfileTab> 
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _cardController;
  late Animation<double> _headerAnimation;
  late Animation<double> _scaleAnimation;
  late List<Animation<Offset>> _slideAnimations;
  
  @override
  void initState() {
    super.initState();
    
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.elasticOut,
    ));
    
    _slideAnimations = List.generate(
      5,
      (index) => Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _cardController,
          curve: Interval(
            index * 0.1,
            0.5 + index * 0.1,
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );
    
    _headerController.forward();
    _cardController.forward();
  }
  
  @override
  void dispose() {
    _headerController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    final safePadding = MediaQuery.of(context).padding;
    
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF0D1117)
          : const Color(0xFFF8FAFC),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return _buildLoginPrompt(context);
          }
          
          return CustomScrollView(
            slivers: [
              // Modern Header
              SliverAppBar(
                expandedHeight: math.min(280.h, screenHeight * 0.4),
                floating: false,
                pinned: true,
                stretch: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      // Gradient Background
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
                                  const Color(0xFF6B73FF),
                                ],
                                transform: GradientRotation(_headerAnimation.value * math.pi),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      // Floating Shapes
                      ...List.generate(3, (index) {
                        return Positioned(
                          left: 40.0 * index + 20,
                          top: 60.0 + (index * 20),
                          child: AnimatedBuilder(
                            animation: _headerAnimation,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _headerAnimation.value * 2 * math.pi + (index * 0.5),
                                child: Container(
                                  width: 50.w + (index * 8),
                                  height: 50.w + (index * 8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.15),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                      
                      // Profile Content
                      SafeArea(
                        child: Padding(
                          padding: EdgeInsets.all(20.w),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 16.h),
                                
                                // Profile Photo with Animation
                                ScaleTransition(
                                  scale: _scaleAnimation,
                                  child: Hero(
                                    tag: 'profile_photo',
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 20,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: const ProfilePhotoUploadWidget(),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                
                                // User Name
                                FadeTransition(
                                  opacity: _headerAnimation,
                                  child: Text(
                                    user.name,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                
                                // User Email
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20.r),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Text(
                                    user.email,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                
                                // Verification Status
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 5.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: user.isEmailVerified
                                        ? const Color(0xFF10B981).withOpacity(0.88)
                                        : const Color(0xFFF59E0B).withOpacity(0.88),
                                    borderRadius: BorderRadius.circular(16.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.10),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        user.isEmailVerified 
                                            ? Icons.verified_rounded 
                                            : Icons.warning_rounded,
                                        size: 14.sp,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        T(context, user.isEmailVerified 
                                            ? 'profile.verified' 
                                            : 'profile.unverified'),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
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
              
              // Content Section with proper constraints
              SliverToBoxAdapter(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenHeight * 0.6 - safePadding.bottom,
                  ),
                  child: SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(
                        20.w, 
                        16.h, 
                        20.w, 
                        safePadding.bottom + MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight // Tab bar + extra space
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Quick Actions Section
                          Text(
                            'Hızlı İşlemler',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : const Color(0xFF1F2937),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          
                          // Action Cards
                          Row(
                            children: [
                              Expanded(
                                child: _buildQuickActionCard(
                                  icon: Icons.edit_rounded,
                                  title: 'Düzenle',
                                  color: const Color(0xFF3B82F6),
                                  onTap: () => _showEditProfileDialog(context, ref, user),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: _buildQuickActionCard(
                                  icon: Icons.lock_rounded,
                                  title: 'Şifre',
                                  color: const Color(0xFFEF4444),
                                  onTap: () => context.push('/change-password'),
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 20.h),
                          
                          // Menu Sections
                          ...List.generate(_getMenuSections(context, user).length, (index) {
                            final section = _getMenuSections(context, user)[index];
                            return SlideTransition(
                              position: _slideAnimations[index],
                              child: _buildMenuSection(
                                context: context,
                                title: section['title'] as String,
                                items: section['items'] as List<Map<String, dynamic>>,
                              ),
                            );
                          }),
                          
                          SizedBox(height: 20.h),
                          
                          // Logout Button - Properly constrained
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: SizedBox(
                              width: double.infinity,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _showLogoutDialog(context, ref),
                                  borderRadius: BorderRadius.circular(16.r),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 14.h),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFEF4444),
                                          Color(0xFFDC2626),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFEF4444).withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.logout_rounded,
                                          color: Colors.white,
                                          size: 18.sp,
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          T(context, 'profile.logout'),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        ),
        error: (error, stack) => _buildErrorState(error),
      ),
    );
  }
  
  Widget _buildLoginPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: EdgeInsets.all(32.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF667EEA).withOpacity(0.1),
                          const Color(0xFF764BA2).withOpacity(0.05),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      size: 64.sp,
                      color: const Color(0xFF667EEA),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 24.h),
            Text(
              T(context, 'profile.login_required'),
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : const Color(0xFF1F2937),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Profilinizi görüntülemek için giriş yapın',
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            FilledButton(
              onPressed: () => context.go('/login'),
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: 40.w,
                  vertical: 14.h,
                ),
                backgroundColor: const Color(0xFF667EEA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.r),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.login_rounded),
                  SizedBox(width: 8.w),
                  Text(
                    T(context, 'profile.login_button'),
                    style: TextStyle(fontSize: 15.sp),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.8),
                color,
              ],
            ),
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 24.sp,
              ),
              SizedBox(height: 6.h),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMenuSection({
    required BuildContext context,
    required String title,
    required List<Map<String, dynamic>> items,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.w, bottom: 10.h),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF21262D)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: items.map((item) {
                final isLast = items.last == item;
                return Column(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: item['onTap'] as VoidCallback,
                        borderRadius: BorderRadius.circular(isLast ? 16.r : 0),
                        child: Padding(
                          padding: EdgeInsets.all(14.w),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: (item['color'] as Color).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Icon(
                                  item['icon'] as IconData,
                                  color: item['color'] as Color,
                                  size: 20.sp,
                                ),
                              ),
                              SizedBox(width: 14.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title'] as String,
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).brightness == Brightness.dark
                                            ? Colors.white
                                            : const Color(0xFF1F2937),
                                      ),
                                    ),
                                    if (item['subtitle'] != null) ...[
                                      SizedBox(height: 2.h),
                                      Text(
                                        item['subtitle'] as String,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 12.sp,
                                color: Colors.grey[400],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (!isLast)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14.w),
                        child: Divider(
                          height: 1,
                          color: Colors.grey.withOpacity(0.2),
                        ),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
  
  List<Map<String, dynamic>> _getMenuSections(BuildContext context, UserModel user) {
    return [
      {
        'title': 'Hesap',
        'items': [
          {
            'icon': Icons.settings_outlined,
            'title': T(context, 'profile.settings'),
            'subtitle': 'Uygulama ayarları',
            'color': const Color(0xFF6366F1),
            'onTap': () => context.push('/settings'),
          },
          {
            'icon': Icons.info_outline_rounded,
            'title': 'Kullanıcı Bilgileri',
            'subtitle': 'Kayıt tarihi ve tercihler',
            'color': const Color(0xFF8B5CF6),
            'onTap': () => _showUserInfoDialog(context, user),
          },
        ],
      },
      {
        'title': 'Destek',
        'items': [
          {
            'icon': Icons.help_outline_rounded,
            'title': T(context, 'profile.help'),
            'subtitle': 'Sıkça sorulan sorular',
            'color': const Color(0xFFF59E0B),
            'onTap': () => context.push('/help'),
          },
          {
            'icon': Icons.info_outline_rounded,
            'title': T(context, 'profile.about'),
            'subtitle': 'Uygulama hakkında',
            'color': const Color(0xFF06B6D4),
            'onTap': () => context.push('/about'),
          },
        ],
      },
    ];
  }
  
  void _showUserInfoDialog(BuildContext context, UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 60.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 22.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Kullanıcı Bilgileri',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                _buildInfoItem(
                  icon: Icons.badge,
                  label: 'Kullanıcı ID',
                  value: user.id,
                  color: const Color(0xFF3B82F6),
                ),
                _buildInfoItem(
                  icon: Icons.calendar_today,
                  label: 'Kayıt Tarihi',
                  value: DateFormat('dd MMMM yyyy, HH:mm', 'tr_TR').format(user.createdAt),
                  color: const Color(0xFF10B981),
                ),
                if (user.birthDate != null)
                  _buildInfoItem(
                    icon: Icons.cake,
                    label: 'Doğum Tarihi',
                    value: DateFormat('dd MMMM yyyy', 'tr_TR').format(user.birthDate!),
                    color: const Color(0xFF6366F1),
                  ),
                if (user.preferences != null && user.preferences!.isNotEmpty)
                  _buildInfoItem(
                    icon: Icons.settings,
                    label: 'Tercihler',
                    value: '${user.preferences!.length} tercih ayarlandı',
                    color: const Color(0xFFF59E0B),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 18.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[500],
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _showEditProfileDialog(BuildContext context, WidgetRef ref, UserModel user) {
    final firstNameController = TextEditingController(text: user.firstName);
    final lastNameController = TextEditingController(text: user.lastName);
    final birthDateController = TextEditingController(
      text: user.birthDate != null
          ? DateFormat('yyyy-MM-dd').format(user.birthDate!)
          : '',
    );
    DateTime? selectedBirthDate = user.birthDate;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 60.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: 22.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Profili Düzenle',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                _buildModernTextField(
                  controller: firstNameController,
                  label: 'Ad',
                  hint: 'Adınızı girin',
                  icon: Icons.person_rounded,
                ),
                SizedBox(height: 14.h),
                _buildModernTextField(
                  controller: lastNameController,
                  label: 'Soyad',
                  hint: 'Soyadınızı girin',
                  icon: Icons.person_rounded,
                ),
                SizedBox(height: 14.h),
                _buildModernTextField(
                  controller: birthDateController,
                  label: 'Doğum Tarihi',
                  hint: 'Doğum tarihinizi seçin',
                  icon: Icons.calendar_today,
                  readOnly: true,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedBirthDate ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      selectedBirthDate = picked;
                      birthDateController.text =
                          DateFormat('yyyy-MM-dd').format(picked);
                    }
                  },
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: const Text('İptal'),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: FilledButton(
                        onPressed: () async {
                          if (firstNameController.text.isEmpty ||
                              lastNameController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Lütfen tüm alanları doldurun'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                            );
                            return;
                          }
                          
                          try {
                            await ref.read(userProvider.notifier).updateUserName(
                              firstNameController.text,
                              lastNameController.text,
                              birthDate: selectedBirthDate,
                            );
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Profil güncellendi'),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Hata: $e'),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        style: FilledButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          backgroundColor: const Color(0xFF3B82F6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: const Text('Kaydet'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF21262D)
            : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: Colors.grey[300]!,
        ),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Container(
            margin: EdgeInsets.all(10.w),
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF3B82F6),
              size: 18.sp,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }
  
  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.r),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.logout_rounded,
                color: Colors.white,
                size: 18.sp,
              ),
            ),
            SizedBox(width: 12.w),
            const Text('Çıkış Yap'),
          ],
        ),
        content: const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(userProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48.sp,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Bir hata oluştu',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : const Color(0xFF1F2937),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              error.toString(),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            FilledButton(
              onPressed: () {
                // Retry action
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF667EEA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }
}