import 'package:ai_performance_intelligence_platform/core/di/injection.dart';
import 'package:ai_performance_intelligence_platform/core/storage/token_storage.dart';
import 'package:ai_performance_intelligence_platform/core/widgets/dashboard_entry.dart';
import 'package:ai_performance_intelligence_platform/features/apps/presentation/page/apps_page.dart';
import 'package:ai_performance_intelligence_platform/features/auth/presentation/screens/login_page.dart';
import 'package:ai_performance_intelligence_platform/features/auth/presentation/screens/signup_page.dart';
import 'package:ai_performance_intelligence_platform/features/auth/presentation/screens/splash_page.dart';
import 'package:ai_performance_intelligence_platform/features/dashboard/presentation/pages/analytics_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) async {
      final tokenStorage = sl<TokenStorage>();
      final token = await tokenStorage.getToken();
      final isLoggedIn = token != null && token.isNotEmpty;

      final isLoggingIn = state.uri.toString() == '/login';
      final isSigningUp = state.uri.toString() == '/signup';
      final isSplash = state.uri.toString() == '/';

      if (!isLoggedIn && !isLoggingIn && !isSigningUp && !isSplash) {
        return '/login';
      }

      if (isLoggedIn && (isLoggingIn || isSplash)) {
        return '/dashboard/analytics';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/login', builder: (context, state) => LoginPage()),
      GoRoute(path: '/signup', builder: (context, state) => SignupPage()),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return DashboardEntry(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            // Redirect base /dashboard to /dashboard/analytics
            redirect: (context, state) => '/dashboard/analytics',
          ),
          GoRoute(
            path: '/dashboard/analytics',
            builder: (context, state) => const AnalyticsPage(),
          ),
          GoRoute(
            path: '/dashboard/apps',
            builder: (context, state) => const AppsPage(),
          ),
        ],
      ),
    ],
  );
}
