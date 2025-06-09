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

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-posta adresi gerekli';
    }
    if (!isValidEmail(value)) {
      return 'Geçerli bir e-posta adresi girin';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre gerekli';
    }
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalı';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Şifre en az bir büyük harf içermeli';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Şifre en az bir küçük harf içermeli';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Şifre en az bir rakam içermeli';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Şifre tekrarı gerekli';
    }
    if (value != password) {
      return 'Şifreler eşleşmiyor';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ad Soyad gerekli';
    }
    if (!isValidName(value)) {
      return 'Geçerli bir ad soyad girin';
    }
    return null;
  }
}
