import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class Utils {
  // İnternet bağlantısı kontrolü
  static Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      // Bu satırı değiştirdik - contains metodu yerine == operatörü kullandık
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      debugPrint('İnternet bağlantısı kontrolü hatası: $e');
      return false;
    }
  }

  // Alternatif metod adı (isteğe bağlı)
  static Future<bool> isInternetAvailable() async {
    return hasInternetConnection();
  }

  // Snackbar gösterme
  static void showSnackBar(BuildContext context, String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Loading dialog gösterme
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Yükleniyor...'),
          ],
        ),
      ),
    );
  }

  // Dialog kapatma
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  // E-mail validasyonu
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Şifre güçlülük kontrolü
  static bool isStrongPassword(String password) {
    return password.length >= 6 &&
           RegExp(r'[a-z]').hasMatch(password) &&
           RegExp(r'[A-Z]').hasMatch(password) &&
           RegExp(r'[0-9]').hasMatch(password);
  }

  // Dosya boyutu formatı
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Zaman formatı
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  // Renk utilities
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  // Ağ bağlantısı dinleyicisi
  static Stream<List<ConnectivityResult>> get connectivityStream {
    return Connectivity().onConnectivityChanged.map((result) => [result]);
  }

  // Async işlem için güvenli context kontrolü
  static bool isContextValid(BuildContext context) {
    try {
      return context.mounted;
    } catch (e) {
      return false;
    }
  }

  // Debug modunda mı kontrolü
  static bool get isDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  // Telefon titreşimi (isteğe bağlı)
  static Future<void> vibrate() async {
    try {
      // HapticFeedback gerekirse import edilebilir
      // await HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Titreşim hatası: $e');
    }
  }

  // URL doğrulama
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  // Async wrapper with error handling
  static Future<T?> safeAsyncCall<T>(Future<T> Function() asyncFunction) async {
    try {
      // Ağ bağlantısını kontrol et
      if (!await hasInternetConnection()) {
        debugPrint('❌ İnternet bağlantısı yok');
        return null;
      }
      
      final result = await asyncFunction();
      return result;
    } catch (e) {
      debugPrint('❌ Async işlem hatası: $e');
      return null;
    }
  }
}
