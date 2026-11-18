import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/profile_completion_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/home_placeholder_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

abstract final class AppRouter {
  static const onboardingCompleteKey = 'bookease_onboarding_complete';
  static const splash = 'splash';
  static const onboarding = 'onboarding';
  static const login = 'login';
  static const register = 'register';
  static const forgotPassword = 'forgot-password';
  static const profileComplete = 'profile-complete';
  static const home = 'home';

  static final router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: kDebugMode,
    refreshListenable: GoRouterRefreshStream(
      GetIt.instance<AuthCubit>().stream,
    ),
    redirect: (context, state) {
      final authState = GetIt.instance<AuthCubit>().state;
      final location = state.matchedLocation;

      final isSplash = location == '/splash';
      final isOnboarding = location == '/onboarding';
      final isPublicAuth =
          location == '/login' ||
          location == '/register' ||
          location == '/forgot-password';
      final isProfileComplete = location == '/profile-complete';

      if (isSplash || isOnboarding) return null;

      if (authState is AuthAuthenticated) {
        if (isPublicAuth || isProfileComplete) return '/home';
        return null;
      }

      if (authState is AuthProfileIncomplete) {
        if (isProfileComplete) return null;
        if (isPublicAuth) return '/profile-complete';
        return null;
      }

      if (authState is AuthLoading || authState is AuthInitial) {
        if (location == '/login' ||
            location == '/register' ||
            location == '/forgot-password') {
          return null;
        }
      }

      if (location == '/home' || isProfileComplete) {
        return '/login';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: splash,
        builder: (_, _) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        name: onboarding,
        builder: (_, _) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/login',
        name: login,
        builder: (_, _) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: register,
        builder: (_, _) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: forgotPassword,
        builder: (_, _) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/profile-complete',
        name: profileComplete,
        builder: (_, _) => const ProfileCompletionPage(),
      ),
      GoRoute(
        path: '/home',
        name: home,
        builder: (_, _) => const HomePlaceholderPage(),
      ),
    ],
  );
}
