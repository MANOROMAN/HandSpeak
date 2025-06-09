import 'package:flutter/material.dart';
import 'package:hand_speak/core/utils/translation_helper.dart' show T;

class ValidationUtils {
  static bool isValidEmail(String email) {
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegExp.hasMatch(email);
  }

  static bool isValidPassword(String password) {
    // En az 6 karakter, 1 büyük harf, 1 küçük harf ve 1 rakam
    final passwordRegExp = RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)[A-Za-z\d]{6,}$',
    );
    return passwordRegExp.hasMatch(password);
  }

  static bool isValidName(String name) {
    // Sadece harf ve boşluk, en az 2 karakter
    final nameRegExp = RegExp(r'^[a-zA-ZğüşıöçĞÜŞİÖÇ ]{2,}$');
    return nameRegExp.hasMatch(name);
  }

  static String? validateEmail(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return T(context, 'auth.validation_email_required');
    }
    if (!isValidEmail(value)) {
      return T(context, 'auth.validation_email_invalid');
    }
    return null;
  }

  static String? validatePassword(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return T(context, 'auth.validation_password_required');
    }
    if (value.length < 6) {
      return T(context, 'auth.validation_password_min_length');
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return T(context, 'auth.validation_password_uppercase');
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return T(context, 'auth.validation_password_lowercase');
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return T(context, 'auth.validation_password_digit');
    }
    return null;
  }

  static String? validateConfirmPassword(BuildContext context, String? value, String password) {
    if (value == null || value.isEmpty) {
      return T(context, 'auth.validation_password_confirm_required');
    }
    if (value != password) {
      return T(context, 'auth.validation_passwords_mismatch');
    }
    return null;
  }

  static String? validateName(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return T(context, 'auth.validation_name_required');
    }
    if (!isValidName(value)) {
      return T(context, 'auth.validation_name_invalid');
    }
    return null;
  }
}
