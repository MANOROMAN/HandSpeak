import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hand_speak/features/auth/screens/login_screen.dart';
import 'package:hand_speak/features/auth/screens/register_screen.dart';
import 'package:hand_speak/features/splash/screens/splash_screen.dart';
import 'package:hand_speak/features/home/screens/home_screen.dart';
import 'package:hand_speak/features/learn/screens/alphabet_screen.dart';
import 'package:hand_speak/features/learn/screens/numbers_screen.dart';
import 'package:hand_speak/features/learn/screens/phrases_screen.dart';
import 'package:hand_speak/features/learn/screens/video_list_screen.dart';
import 'package:hand_speak/features/learn/screens/quiz_screen.dart';
import 'package:hand_speak/features/learn/screens/quiz_category_screen.dart';
import 'package:hand_speak/features/learn/screens/web_view_screen.dart';
import 'package:hand_speak/features/learn/screens/video_player_screen.dart';
import 'package:hand_speak/features/auth/screens/about_page.dart';
import 'package:hand_speak/features/settings/screens/change_password_screen.dart';
import 'package:hand_speak/features/settings/screens/help_page.dart';
import 'package:hand_speak/features/settings/screens/settings_screen.dart';
// my_videos_screen.dart removed - functionality merged into video_gallery_screen.dart
import 'package:hand_speak/features/videos/screens/video_gallery_screen.dart';
import 'package:hand_speak/providers/user_provider.dart';
import 'package:hand_speak/providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final currentLocation = state.uri.toString();

      // Splash ekranını kontrol et
      if (currentLocation == '/splash') return null;

      // Authentication state kontrolü
      final bool loggedIn = isAuthenticated;

      // Authentication sayfalarını tanımla
      final bool isAuthRoute = currentLocation == '/login' || 
                               currentLocation == '/register' ||
                               currentLocation == '/email-verification';

      // Eğer giriş yapmamış ve auth sayfasında değilse, login'e yönlendir
      if (!loggedIn && !isAuthRoute) {
        return '/login';
      }

      // Eğer giriş yapmış ve auth sayfalarındaysa, ana sayfaya yönlendir
      if (loggedIn && isAuthRoute) {
        return '/';
      }

      return null;
    },
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
        path: '/',
        builder: (context, state) => const ModernHomeScreen(),
      ),
      // Learning routes with video content
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
          url: 'https://research.sign.mt/',
        ),
      ),
      GoRoute(
        path: '/learn/quiz-categories',
        builder: (context, state) => const QuizCategoryScreen(),
      ),
      GoRoute(
        path: '/learn/quiz',
        builder: (context, state) {
          final categoryId = state.uri.queryParameters['category'] ?? 
                            (state.extra is Map ? (state.extra as Map)['categoryId']?.toString() : null);
          return ModernQuizScreen(categoryId: categoryId);
        },
      ),
      GoRoute(
        path: '/video-player',
        builder: (context, state) {
          final extra = state.extra as Map<String, String>;
          return ModernVideoPlayerScreen(
            videoId: extra['videoId']!,
            title: extra['title']!,
          );
        },
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutPage(),
      ),
      GoRoute(
        path: '/help',
        builder: (context, state) => const UltraModernHelpPage(),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/videos',
        builder: (context, state) => const UnifiedVideoScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  );
});
