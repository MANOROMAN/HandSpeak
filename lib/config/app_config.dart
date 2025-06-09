class AppConfig {
  static const String appName = 'Hand Speak';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = 'https://api.handspeak.com';
  static const int apiTimeout = 30000; // 30 seconds

  // Firebase Configuration
  static const String firebaseProjectId = 'hand-speak';
  static const String firebaseMessagingSenderId = 'your-sender-id';

  // Feature Flags
  static const bool enableGoogleSignIn = true;
  static const bool enableEmailSignIn = true;
  static const bool enableAppleSignIn = false;
  static const bool enableOfflineMode = true;

  // Cache Configuration
  static const int maxCacheAge = 7; // days
  static const int maxCacheSize = 50; // MB

  // ML Model Configuration
  static const String modelPath = 'assets/models/hand_speak_model.tflite';
  static const int inputSize = 224;
  static const int numThreads = 4;

  // App Settings
  static const List<String> supportedLanguages = ['en', 'tr'];
  static const String defaultLanguage = 'en';
  static const bool enablePushNotifications = true;
  static const bool enableCrashReporting = true;
  static const bool enableAnalytics = true;
}
