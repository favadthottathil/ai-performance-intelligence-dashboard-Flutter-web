import 'package:ai_performance_intelligence_platform/core/di/injection.dart';
import 'package:ai_performance_intelligence_platform/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ai_performance_intelligence_platform/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_web_plugins/url_strategy.dart'; // Import this
import 'package:flutter/foundation.dart'; // Import for kIsWeb

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    usePathUrlStrategy();
  }
  await configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (context) => sl<AuthBloc>(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'AI Performance Platform',
        theme: _buildModernTheme(),
        routerConfig: AppRouter.router,
      ),
    );
  }

  ThemeData _buildModernTheme() {
    final base = ThemeData.dark();
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    );

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF0F172A), // Dark slate blue
      textTheme: textTheme,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF3B82F6), // Neon Blue
        secondary: Color(0xFF8B5CF6), // Violet
        surface: Color(0xFF1E293B), // Slate 800
        background: Color(0xFF0F172A),
        onPrimary: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIconColor: Colors.white70,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: const Color(0xFF3B82F6).withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      // cardTheme commented out due to potential analyzer conflict
      // cardTheme: CardTheme(
      //   color: const Color(0xFF1E293B),
      //   elevation: 0,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(16),
      //     side: BorderSide(color: Colors.white.withOpacity(0.05)),
      //   ),
      // ),
    );
  }
}
