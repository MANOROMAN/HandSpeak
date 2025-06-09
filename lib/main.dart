import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
// Import what we need for the MyApp class
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hand_speak/core/theme/app_theme.dart';
import 'package:hand_speak/providers/settings_provider.dart';
import 'package:hand_speak/providers/language_provider.dart';
import 'package:hand_speak/providers/router_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hand_speak/core/localization/app_localizations.dart';
import 'package:hand_speak/firebase_options.dart';
import 'package:hand_speak/core/services/storage_service.dart';
import 'package:hand_speak/providers/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

// MyApp class definition right in main.dart
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(languageProvider);

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Hand Speak',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ref.watch(appSettingsProvider).themeMode,
          routerConfig: ref.watch(routerProvider),
          debugShowCheckedModeBanner: false,
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('tr'),
          ],
        );
      },
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ekranı dikey moda sabitle
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Tam ekran modu - sistem navigasyon düğmelerini gizle
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [], // Hiçbir sistem arayüzü görünmeyecek
  );
  
  // Uygulamanın açılışında izinleri kontrol et ve kaydet
  await _checkPermissionsOnStart();
  
  // Firebase başlat
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // App Check'i etkinleştir
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
    );
    
    debugPrint('Firebase başarıyla başlatıldı');
  } catch (e, stackTrace) {
    if (e is FirebaseException && e.code == 'duplicate-app') {
      debugPrint('Firebase zaten başlatılmış');
    } else {
      debugPrint('Firebase başlatma hatası: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  // Hive başlat
  await Hive.initFlutter();

  // Storage service
  final storageService = await StorageService.getInstance();

  // SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Sistem UI görünümünü ayarla - tam ekran için
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      storageServiceProvider.overrideWithValue(storageService),
    ],
  );

  // Initialize language provider to ensure translations are loaded
  try {
    final languageController = container.read(languageProvider.notifier);
    debugPrint('🌐 Language provider initialized');
  } catch (e) {
    debugPrint('❌ Error initializing language provider: $e');
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

// StorageService için Provider
final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError();
});

// Uygulamanın açılışında izinleri kontrol et
Future<void> _checkPermissionsOnStart() async {
  try {
    // Önceki izinleri kontrol et
    final prefs = await SharedPreferences.getInstance();
    final permissionsGranted = prefs.getBool('permissions_granted') ?? false;
    
    debugPrint('İzinler daha önce verilmiş mi: $permissionsGranted');
    
    if (!permissionsGranted) {
      // İzin durumlarını kontrol et
      final cameraStatus = await Permission.camera.status;
      final microphoneStatus = await Permission.microphone.status;
      
      debugPrint('Kamera izni: $cameraStatus');
      debugPrint('Mikrofon izni: $microphoneStatus');
      
      // Eğer izinler zaten verilmişse kaydet
      if (cameraStatus.isGranted && microphoneStatus.isGranted) {
        await prefs.setBool('permissions_granted', true);
      }
    }
  } catch (e) {
    debugPrint('İzin kontrolü hatası: $e');
  }
}