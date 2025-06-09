import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hand_speak/core/utils/translation_helper.dart' show T;
import 'package:hand_speak/providers/auth_provider.dart';
import 'package:hand_speak/widgets/common_widgets.dart';
import 'dart:async';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  final String email;
  
  const EmailVerificationScreen({
    Key? key, 
    required this.email,
  }) : super(key: key);

  @override
  ConsumerState<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends ConsumerState<EmailVerificationScreen> {
  // Verification code controllers
  final List<TextEditingController> _controllers = List.generate(
    6, (_) => TextEditingController()
  );
  
  // Focus nodes for each digit field
  final List<FocusNode> _focusNodes = List.generate(
    6, (_) => FocusNode()
  );
  
  // Counter for resending code
  Timer? _timer;
  int _countDown = 60;
  bool _canResend = false;
  
  // Verification status
  bool _isVerifying = false;
  bool _isResending = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startCountdownTimer();
    
    // Auto-focus on first digit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    });
  }
  
  @override
  void dispose() {
    // Clean up controllers and focus nodes
    for (final controller in _controllers) {
      controller.dispose();
    }
    
    for (final node in _focusNodes) {
      node.dispose();
    }
    
    _timer?.cancel();
    super.dispose();
  }
  
  void _startCountdownTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countDown > 0) {
          _countDown--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }
  
  // Function to handle digit input and focus change
  void _handleDigitInput(String value, int index) {
    if (value.isEmpty) return;
    
    // Auto advance focus to next field
    if (index < 5 && value.isNotEmpty) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    }
    
    // Check if all digits are filled
    if (index == 5) {
      _verifyCode();
    }
  }
  
  // Get the full verification code from all text fields
  String get _verificationCode {
    return _controllers.map((c) => c.text).join();
  }
  
  // Verify entered code
  Future<void> _verifyCode() async {
    final code = _verificationCode;
    
    // Validation: ensure 6 digits are entered
    if (code.length != 6) {
      setState(() {
        _errorMessage = T(context, 'auth.verification_code_incomplete');
      });
      return;
    }
    
    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });
    
    try {
      final authService = ref.read(authServiceProvider);
      final success = await authService.verifyEmailCode(
        email: widget.email, 
        code: code
      );
      
      if (!mounted) return;
      
      if (success) {
        final userId = authService.currentUser?.uid;
        if (userId != null) {
          await authService.markEmailVerified(userId);
          await ref.read(userProvider.notifier).refreshUserProfile();
        }

        // Navigate to home screen on success
        context.go('/');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(T(context, 'auth.verification_success')),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _errorMessage = T(context, 'auth.verification_failed');
        });
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }
  
  // Resend verification code
  Future<void> _resendCode() async {
    if (!_canResend) return;
    
    setState(() {
      _isResending = true;
      _errorMessage = null;
    });
    
    try {
      final authService = ref.read(authServiceProvider);
      await authService.sendVerificationCode(widget.email);
      
      if (!mounted) return;
      
      // Reset countdown timer
      setState(() {
        _countDown = 60;
        _canResend = false;
      });
      
      _startCountdownTimer();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(T(context, 'auth.code_resent')),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTurkish = Localizations.localeOf(context).languageCode == 'tr';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(T(context, 'auth.verify_email')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon
                Icon(
                  Icons.email_outlined,
                  size: 80.w,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(height: 24.h),
                
                // Title
                Text(
                  T(context, 'auth.verification_title'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                
                // Description
                Text(
                  T(context, 'auth.verification_description')
                    .replaceAll('{email}', widget.email),
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.h),
                
                // Verification code fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 45.w,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(
                              color: _errorMessage != null 
                                ? Colors.red 
                                : Colors.grey.shade300,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 14.h,
                            horizontal: 0,
                          ),
                        ),
                        onChanged: (value) {
                          _handleDigitInput(value, index);
                          
                          // Support backspace navigation between fields
                          if (value.isEmpty && index > 0) {
                            FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
                          }
                          
                          // Clear error when typing
                          if (_errorMessage != null) {
                            setState(() {
                              _errorMessage = null;
                            });
                          }
                        },
                      ),
                    );
                  }),
                ),
                SizedBox(height: 16.h),
                
                // Error message
                if (_errorMessage != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),                  // Verify button
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    onPressed: _isVerifying ? () {} : () => _verifyCode(),
                    isLoading: _isVerifying,
                    text: T(context, 'auth.verify_code'),
                  ),
                ),
                SizedBox(height: 24.h),
                
                // Resend code
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      T(context, 'auth.didnt_receive_code'),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    TextButton(
                      onPressed: _canResend && !_isResending ? _resendCode : null,
                      child: _isResending
                        ? SizedBox(
                            width: 16.w,
                            height: 16.w,
                            child: CircularProgressIndicator(strokeWidth: 2.w),
                          )
                        : Text(
                            _canResend 
                              ? T(context, 'auth.resend_code')
                              : isTurkish
                                  ? '${_countDown}s sonra yeniden gönder'
                                  : 'Resend in ${_countDown}s',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
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
}
