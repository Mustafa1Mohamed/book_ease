import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/profile_completion_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/cubit/patient_home_cubit.dart';
import '../../features/home/presentation/pages/patient_home_page.dart';
import '../../features/home/presentation/pages/patient_home_shell_page.dart';
import '../../features/home/presentation/widgets/home_tab_placeholder.dart';
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
  static const explore = 'explore';
  static const appointments = 'appointments';
  static const profile = 'profile';

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
      final isPatientArea =
          location == '/home' ||
          location == '/explore' ||
          location == '/appointments' ||
          location == '/profile';

      if (isSplash || isOnboarding) return null;

      if (authState is AuthAuthenticated) {
        if (isPublicAuth || isProfileComplete) return '/home';
        return null;
      }

      if (authState is AuthProfileIncomplete) {
        if (isProfileComplete) return null;
        if (isPublicAuth || isPatientArea) return '/profile-complete';
        return null;
      }

      if (authState is AuthLoading || authState is AuthInitial) {
        if (location == '/login' ||
            location == '/register' ||
            location == '/forgot-password') {
          return null;
        }
      }

      if (isPatientArea || isProfileComplete) {
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
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) =>
            PatientHomeShellPage(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: home,
                builder: (_, _) => BlocProvider(
                  create: (_) => GetIt.instance<PatientHomeCubit>()..load(),
                  child: const PatientHomePage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/explore',
                name: explore,
                builder: (_, _) => const HomeTabPlaceholder(
                  title: 'Explore',
                  message:
                      'Doctor and specialty browsing will be available here.',
                  icon: Icons.explore_rounded,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/appointments',
                name: appointments,
                builder: (_, _) => const HomeTabPlaceholder(
                  title: 'Appointments',
                  message: 'Your appointment management tools will be available here.',
                  icon: Icons.calendar_month_rounded,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: profile,
                builder: (_, _) => const HomeTabPlaceholder(
                  title: 'Profile',
                  message: 'Patient profile settings will be available here.',
                  icon: Icons.person_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
