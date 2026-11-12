import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'data/models/movie_model.dart';
import 'ui/screens/auth/forgot_password_screen.dart';
import 'ui/screens/auth/login_screen.dart';
import 'ui/screens/auth/register_screen.dart';
import 'ui/screens/details/movie_details_screen.dart';
import 'ui/screens/main_layout/main_layout_screen.dart';
import 'ui/screens/onboarding/onboarding_screen.dart';
import 'ui/screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Transparent dark status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Firebase (safely)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase Core initialization notice: $e');
  }

  runApp(const MoviesApp());
}

class MoviesApp extends StatelessWidget {
  const MoviesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CineFlix - Graduation Project 🎬',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/main': (context) => const MainLayoutScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/movie-details') {
          final movie = settings.arguments as MovieModel;
          return MaterialPageRoute(
            builder: (context) => MovieDetailsScreen(movie: movie),
          );
        }
        return null;
      },
    );
  }
}
