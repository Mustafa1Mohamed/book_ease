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
import '../../features/explore/presentation/cubit/explore_cubit.dart';
import '../../features/explore/presentation/pages/explore_page.dart';
import '../../features/doctors/presentation/cubit/doctor_details_cubit.dart';
import '../../features/doctors/presentation/pages/doctor_details_page.dart';
import '../../features/booking/presentation/cubit/booking_cubit.dart';
import '../../features/booking/presentation/pages/booking_page.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
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
  static const doctorDetails = 'doctor-details';
  static const booking = 'booking';

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
          location.startsWith('/home') ||
          location.startsWith('/explore') ||
          location.startsWith('/appointments') ||
          location.startsWith('/profile');

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
                builder: (_, _) => BlocProvider(
                  create: (_) => GetIt.instance<ExploreCubit>()..load(),
                  child: const ExplorePage(),
                ),
                routes: [
                  GoRoute(
                    path: 'doctor/:doctorId',
                    name: doctorDetails,
                    builder: (_, state) {
                      final doctorId = state.pathParameters['doctorId'] ?? '';
                      return BlocProvider(
                        create: (_) =>
                            GetIt.instance<DoctorDetailsCubit>()
                              ..load(doctorId),
                        child: DoctorDetailsPage(doctorId: doctorId),
                      );
                    },
                    routes: [
                      GoRoute(
                        path: 'book',
                        name: booking,
                        builder: (_, state) {
                          final doctorId =
                              state.pathParameters['doctorId'] ?? '';
                          return BlocProvider(
                            create: (_) =>
                                GetIt.instance<BookingCubit>()..load(doctorId),
                            child: BookingPage(doctorId: doctorId),
                          );
                        },
                      ),
                    ],
                  ),
                ],
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
                builder: (_, _) => BlocProvider(
                  create: (_) => GetIt.instance<ProfileCubit>()..load(),
                  child: const ProfilePage(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
