import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hand_speak/providers/user_provider.dart';
import 'package:hand_speak/providers/settings_provider.dart';
import 'package:hand_speak/providers/language_provider.dart';
import 'package:hand_speak/core/utils/translation_helper.dart' show T;
import 'package:hand_speak/debug/firebase_storage_diagnostic_widget.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final currentLocale = ref.watch(languageProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.grey.shade50,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          T(context, 'settings.title'),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        leading: Container(
          margin: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: theme.cardColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: theme.dividerColor.withOpacity(0.2),
            ),
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: theme.iconTheme.color,
              size: 20.sp,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ListView(
              padding: EdgeInsets.all(20.w),
              children: [
                SizedBox(height: 20.h),
                
                // Header Card
                Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                        ? [
                            theme.primaryColor.withOpacity(0.2),
                            theme.primaryColor.withOpacity(0.1),
                          ]
                        : [
                            theme.primaryColor.withOpacity(0.1),
                            theme.primaryColor.withOpacity(0.05),
                          ],
                    ),
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(
                      color: theme.primaryColor.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60.w,
                        height: 60.w,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.primaryColor,
                              theme.primaryColor.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: theme.primaryColor.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.settings_rounded,
                          color: Colors.white,
                          size: 28.sp,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              T(context, 'settings.header_title'),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              T(context, 'settings.header_subtitle'),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 24.h),
                
                // Display Settings
                _buildSection(
                  context,
                  title: T(context, 'settings.theme'),
                  icon: Icons.palette_rounded,
                  iconColor: Colors.blue,
                  children: [
                    _buildThemeModeSettingTile(context, settings, ref, theme),
                    _buildLanguageSettingTile(context, currentLocale, ref, theme),
                  ],
                ),
                
                SizedBox(height: 20.h),
                
                // Account Settings
                _buildSection(
                  context,
                  title: T(context, 'settings.account'),
                  icon: Icons.account_circle_rounded,
                  iconColor: Colors.green,
                  children: [
                    _buildUserIdSettingTile(context, settings, ref, theme),
                    _buildChangePasswordTile(context, ref, theme),
                  ],
                ),
                
                SizedBox(height: 20.h),
                
                // Video Settings
                _buildSection(
                  context,
                  title: T(context, 'settings.video_quality'),
                  icon: Icons.videocam_rounded,
                  iconColor: Colors.purple,
                  children: [
                    _buildVideoQualityTile(context, theme),
                  ],
                ),
                
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: theme.dividerColor.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : Colors.grey).withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeModeSettingTile(BuildContext context, dynamic settings, WidgetRef ref, ThemeData theme) {
    return _buildSettingTile(
      context,
      title: T(context, 'settings.theme_mode'),
      subtitle: T(context, 'settings.theme_mode_description'),
      icon: theme.brightness == Brightness.dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
      trailing: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: theme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: theme.primaryColor.withOpacity(0.3),
          ),
        ),
        child: DropdownButton<ThemeMode>(
          value: settings.themeMode,
          underline: const SizedBox(),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: theme.primaryColor,
            size: 20.sp,
          ),
          style: TextStyle(
            color: theme.primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
          onChanged: (ThemeMode? newMode) {
            if (newMode != null) {
              ref.read(appSettingsProvider.notifier).setThemeMode(newMode);
            }
          },
          items: ThemeMode.values.map((ThemeMode mode) {
            String modeText;
            switch (mode) {
              case ThemeMode.light:
                modeText = T(context, 'settings.light');
                break;
              case ThemeMode.dark:
                modeText = T(context, 'settings.dark');
                break;
              case ThemeMode.system:
                modeText = T(context, 'settings.system');
                break;
            }
            return DropdownMenuItem(
              value: mode,
              child: Text(modeText),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLanguageSettingTile(BuildContext context, Locale currentLocale, WidgetRef ref, ThemeData theme) {
    return _buildSettingTile(
      context,
      title: T(context, 'settings.language'),
      subtitle: T(context, 'settings.language_subtitle'),
      icon: Icons.language_rounded,
      trailing: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: Colors.green.withOpacity(0.3),
          ),
        ),
        child: DropdownButton<String>(
          value: currentLocale.languageCode,
          underline: const SizedBox(),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.green,
            size: 20.sp,
          ),
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
          onChanged: (String? newLocale) {
            if (newLocale != null) {
              ref.read(languageProvider.notifier).setLanguage(Locale(newLocale));
              ref.read(appSettingsProvider.notifier).setLocale(Locale(newLocale));
            }
          },
          items: [
            DropdownMenuItem(
              value: 'tr',
              child: Text('Türkçe'),
            ),
            DropdownMenuItem(
              value: 'en',
              child: Text('English'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserIdSettingTile(BuildContext context, dynamic settings, WidgetRef ref, ThemeData theme) {
    return _buildSettingTile(
      context,
      title: T(context, 'settings.show_user_id_title'),
      subtitle: T(context, 'settings.show_user_id_subtitle'),
      icon: Icons.badge_rounded,
      trailing: Switch.adaptive(
        value: settings.showUserId,
        activeColor: Colors.green,
        onChanged: (value) {
          ref.read(appSettingsProvider.notifier).setShowUserId(value);
        },
      ),
    );
  }

  Widget _buildChangePasswordTile(BuildContext context, WidgetRef ref, ThemeData theme) {
    return _buildSettingTile(
      context,
      title: T(context, 'settings.change_password'),
      subtitle: T(context, 'settings.change_password_subtitle'),
      icon: Icons.lock_reset_rounded,
      trailing: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.blue,
          size: 16.sp,
        ),
      ),
      onTap: () {
        _showChangePasswordDialog(context, ref);
      },
    );
  }

  Widget _buildVideoQualityTile(BuildContext context, ThemeData theme) {
    return _buildSettingTile(
      context,
      title: T(context, 'settings.video_quality'),
      subtitle: T(context, 'settings.video_quality_subtitle'),
      icon: Icons.high_quality_rounded,
      trailing: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.purple,
          size: 16.sp,
        ),
      ),
      onTap: () {
        Navigator.of(context).pushNamed('/video-quality');
      },
    );
  }

  Widget _buildSettingTile(BuildContext context, {
    required String title,
    String? subtitle,
    required IconData icon,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: theme.primaryColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isLoading = false;
    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          
          return AlertDialog(
            backgroundColor: theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.lock_reset_rounded,
                    color: theme.primaryColor,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  T(context, 'settings.change_password_dialog_title'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDialogPasswordField(
                      controller: currentPasswordController,
                      label: T(context, 'settings.current_password'),
                      hint: T(context, 'settings.current_password_hint'),
                      obscureText: obscureCurrentPassword,
                      onToggle: () => setState(() => obscureCurrentPassword = !obscureCurrentPassword),
                      theme: theme,
                    ),
                    SizedBox(height: 16.h),
                    _buildDialogPasswordField(
                      controller: newPasswordController,
                      label: T(context, 'settings.new_password'),
                      hint: T(context, 'settings.new_password_hint'),
                      obscureText: obscureNewPassword,
                      onToggle: () => setState(() => obscureNewPassword = !obscureNewPassword),
                      theme: theme,
                    ),
                    SizedBox(height: 16.h),
                    _buildDialogPasswordField(
                      controller: confirmPasswordController,
                      label: T(context, 'settings.confirm_new_password'),
                      hint: T(context, 'settings.new_password_confirm_hint'),
                      obscureText: obscureConfirmPassword,
                      onToggle: () => setState(() => obscureConfirmPassword = !obscureConfirmPassword),
                      theme: theme,
                    ),
                    if (isLoading) ...[
                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            T(context, 'settings.changing_password'),
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  T(context, 'settings.cancel'),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              FilledButton(
                onPressed: isLoading ? null : () async {
                  // Form validation
                  if (currentPasswordController.text.isEmpty ||
                      newPasswordController.text.isEmpty ||
                      confirmPasswordController.text.isEmpty) {
                    _showErrorMessage(context, T(context, 'auth.fill_all_fields'));
                    return;
                  }

                  if (newPasswordController.text != confirmPasswordController.text) {
                    _showErrorMessage(context, T(context, 'auth.validation_passwords_mismatch'));
                    return;
                  }

                  if (newPasswordController.text.length < 6) {
                    _showErrorMessage(context, T(context, 'auth.validation_password_min_length'));
                    return;
                  }

                  setState(() => isLoading = true);

                  try {
                    await ref.read(userProvider.notifier).changePassword(
                          currentPasswordController.text,
                          newPasswordController.text,
                        );
                    if (context.mounted) {
                      Navigator.pop(context);
                      _showSuccessMessage(context, T(context, 'settings.password_changed'));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      _showErrorMessage(context, e.toString());
                      setState(() => isLoading = false);
                    }
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  T(context, 'settings.change_button'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDialogPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggle,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
          ),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
            ),
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: theme.iconTheme.color?.withOpacity(0.6),
                size: 18.sp,
              ),
            ),
            filled: true,
            fillColor: theme.primaryColor.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: theme.dividerColor.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: theme.dividerColor.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: theme.primaryColor,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 12.h,
            ),
          ),
        ),
      ],
    );
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                color: Colors.green,
                size: 16.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 16.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }
}