import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hand_speak/features/auth/screens/login_screen.dart';
import 'package:hand_speak/features/auth/screens/register_screen.dart';
import 'package:hand_speak/features/auth/screens/change_password_screen.dart';
import 'package:hand_speak/features/home/screens/home_screen.dart';
import 'package:hand_speak/features/learning/screens/learning_screen.dart';
import 'package:hand_speak/features/settings/screens/settings_screen.dart';
import 'package:hand_speak/features/splash/screens/splash_screen.dart';
import 'package:hand_speak/features/settings/screens/help_page.dart';
import 'package:hand_speak/features/auth/screens/about_page.dart';
// my_videos_screen.dart removed - functionality merged into video_gallery_screen.dart
import 'package:hand_speak/features/videos/screens/video_gallery_screen.dart';
import 'package:hand_speak/features/settings/screens/video_quality_screen.dart';
import 'package:hand_speak/features/learn/screens/alphabet_screen.dart';
import 'package:hand_speak/features/learn/screens/numbers_screen.dart';
import 'package:hand_speak/features/learn/screens/phrases_screen.dart';
import 'package:hand_speak/features/learn/screens/video_list_screen.dart';
import 'package:hand_speak/features/learn/screens/quiz_screen.dart';
import 'package:hand_speak/features/learn/screens/web_view_screen.dart';
import 'package:hand_speak/features/learn/screens/video_player_screen.dart';
import 'package:hand_speak/features/auth/screens/email_verification_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/email-verification',
        builder: (context, state) {
          final extra = state.extra as Map<String, String>?;
          if (extra == null || !extra.containsKey('email')) {
            return const Scaffold(
              body: Center(child: Text('E-posta bilgisi eksik')),
            );
          }
          return EmailVerificationScreen(email: extra['email']!);
        },
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const ModernHomeScreen(),
      ),
      GoRoute(
        path: '/learning',
        builder: (context, state) => const LearningScreen(),
      ),
      GoRoute(
        path: '/learn/alphabet',
        builder: (context, state) => const AlphabetScreen(),
      ),
      GoRoute(
        path: '/learn/numbers',
        builder: (context, state) => const NumbersScreen(),
      ),
      GoRoute(
        path: '/learn/phrases',
        builder: (context, state) => const PhrasesScreen(),
      ),
      GoRoute(
        path: '/learn/daily-words',
        builder: (context, state) => const ModernVideoListScreen(categoryId: 'daily_words'),
      ),
      GoRoute(
        path: '/learn/research',
        builder: (context, state) => const EnhancedWebViewScreen(
          title: 'İşaret Dili Araştırma',
          url: 'https://www.handspeak.com/',
        ),
      ),
      GoRoute(
        path: '/learn/quiz',
        builder: (context, state) => const ModernQuizScreen(),
      ),
      GoRoute(
        path: '/video-player',
        builder: (context, state) {
          final extra = state.extra as Map<String, String>?;
          if (extra == null) {
            throw Exception('Video player requires videoId and title parameters');
          }
          return ModernVideoPlayerScreen(
            videoId: extra['videoId']!,
            title: extra['title']!,
          );
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/help',
        builder: (context, state) => const UltraModernHelpPage(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutPage(),
      ),
      GoRoute(
        path: '/videos',
        builder: (context, state) => const UnifiedVideoScreen(),
      ),
      GoRoute(
        path: '/video-quality',
        builder: (context, state) => const VideoSettingsBottomSheet(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Sayfa Bulunamadı')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Aradığınız sayfa bulunamadı',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Route: ${state.uri}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Ana Sayfaya Dön'),
            ),
          ],
        ),
      ),
    ),
  );

  return router;
});
