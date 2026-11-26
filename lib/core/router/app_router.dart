import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/profile_completion_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/account_status_page.dart';
import '../../features/auth/domain/entities/app_user.dart';
import '../../features/auth/domain/entities/user_role.dart';
import '../../features/admin/presentation/cubit/admin_dashboard_cubit.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/cubit/admin_doctor_list_cubit.dart';
import '../../features/admin/presentation/cubit/admin_doctor_details_cubit.dart';
import '../../features/admin/presentation/pages/admin_doctor_list_page.dart';
import '../../features/admin/presentation/pages/admin_doctor_details_page.dart';
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
import '../../features/my_appointments/presentation/cubit/appointment_details_cubit.dart';
import '../../features/my_appointments/presentation/cubit/my_appointments_cubit.dart';
import '../../features/my_appointments/presentation/pages/appointment_details_page.dart';
import '../../features/my_appointments/presentation/pages/my_appointments_page.dart';
import '../../features/doctor_dashboard/presentation/cubit/doctor_appointment_details_cubit.dart';
import '../../features/doctor_dashboard/presentation/cubit/doctor_dashboard_cubit.dart';
import '../../features/doctor_dashboard/presentation/pages/doctor_appointment_details_page.dart';
import '../../features/doctor_dashboard/presentation/pages/doctor_dashboard_page.dart';
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
  static const accountStatus = 'account-status';
  static const adminDashboard = 'admin-dashboard';
  static const adminDoctors = 'admin-doctors';
  static const adminDoctorDetails = 'admin-doctor-details';
  static const home = 'home';
  static const explore = 'explore';
  static const appointments = 'appointments';
  static const appointmentDetails = 'appointmentDetails';
  static const doctorDashboard = 'doctor-dashboard';
  static const doctorAppointmentDetails = 'doctor-appointment-details';
  static const profile = 'profile';
  static const doctorDetails = 'doctor-details';
  static const booking = 'booking';

  static String? redirectFor(AuthState authState, String location) {
    final isSplash = location == '/splash';
    final isOnboarding = location == '/onboarding';
    final isPublicAuth =
        location == '/login' ||
        location == '/register' ||
        location == '/forgot-password';
    final isProfileComplete = location == '/profile-complete';
    final isAccountStatus = location == '/account-status';
    final isAdminArea = location.startsWith('/admin');
    final isDoctorArea = location.startsWith('/doctor-dashboard');
    final isPatientArea =
        location.startsWith('/home') ||
        location.startsWith('/explore') ||
        location.startsWith('/appointments') ||
        location.startsWith('/profile');

    if (isSplash || isOnboarding) return null;

    if (authState is AuthAuthenticated) {
      final user = authState.user;
      return _authenticatedRedirect(
        user,
        isPublicAuth: isPublicAuth,
        isProfileComplete: isProfileComplete,
        isAccountStatus: isAccountStatus,
        isAdminArea: isAdminArea,
        isDoctorArea: isDoctorArea,
        isPatientArea: isPatientArea,
      );
    }

    if (authState is AuthProfileIncomplete) {
      return isProfileComplete ? null : '/profile-complete';
    }

    if (authState is AuthInitial || authState is AuthLoading) {
      return isPublicAuth ? null : '/login';
    }

    if (isPublicAuth) return null;
    return '/login';
  }

  static String _defaultLocationFor(AppUser user) {
    return switch (user.role) {
      UserRole.patient => '/home',
      UserRole.doctor =>
        user.doctorLifecycleStatus.canOperate
            ? '/doctor-dashboard'
            : '/account-status',
      UserRole.admin => '/admin',
      UserRole.unknown => '/account-status',
    };
  }

  static String? _authenticatedRedirect(
    AppUser user, {
    required bool isPublicAuth,
    required bool isProfileComplete,
    required bool isAccountStatus,
    required bool isAdminArea,
    required bool isDoctorArea,
    required bool isPatientArea,
  }) {
    switch (user.role) {
      case UserRole.patient:
        if (isPublicAuth ||
            isProfileComplete ||
            isAccountStatus ||
            isAdminArea ||
            isDoctorArea) {
          return _defaultLocationFor(user);
        }
        return isPatientArea ? null : _defaultLocationFor(user);
      case UserRole.doctor:
        if (!user.doctorLifecycleStatus.canOperate) {
          return isAccountStatus ? null : _defaultLocationFor(user);
        }
        return isDoctorArea ? null : _defaultLocationFor(user);
      case UserRole.admin:
        return isAdminArea ? null : _defaultLocationFor(user);
      case UserRole.unknown:
        return isAccountStatus ? null : _defaultLocationFor(user);
    }
  }

  static final router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: kDebugMode,
    refreshListenable: GoRouterRefreshStream(
      GetIt.instance<AuthCubit>().stream,
    ),
    redirect: (context, state) {
      final authState = GetIt.instance<AuthCubit>().state;
      return redirectFor(authState, state.matchedLocation);
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
        path: '/account-status',
        name: accountStatus,
        builder: (_, _) => const AccountStatusPage(),
      ),
      GoRoute(
        path: '/admin',
        name: adminDashboard,
        builder: (_, _) => BlocProvider(
          create: (_) => GetIt.instance<AdminDashboardCubit>()..load(),
          child: const AdminDashboardPage(),
        ),
        routes: [
          GoRoute(
            path: 'doctors',
            name: adminDoctors,
            builder: (_, _) => BlocProvider(
              create: (_) => GetIt.instance<AdminDoctorListCubit>()..load(),
              child: const AdminDoctorListPage(),
            ),
            routes: [
              GoRoute(
                path: ':doctorId',
                name: adminDoctorDetails,
                builder: (_, state) {
                  final doctorId = state.pathParameters['doctorId'] ?? '';
                  return BlocProvider(
                    create: (_) =>
                        GetIt.instance<AdminDoctorDetailsCubit>()
                          ..load(doctorId),
                    child: AdminDoctorDetailsPage(doctorId: doctorId),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/doctor-dashboard',
        name: doctorDashboard,
        builder: (_, _) => BlocProvider(
          create: (_) => GetIt.instance<DoctorDashboardCubit>()..load(),
          child: const DoctorDashboardPage(),
        ),
        routes: [
          GoRoute(
            path: 'appointments/:appointmentId',
            name: doctorAppointmentDetails,
            builder: (_, state) {
              final appointmentId = state.pathParameters['appointmentId'] ?? '';
              return BlocProvider(
                create: (_) =>
                    GetIt.instance<DoctorAppointmentDetailsCubit>()
                      ..load(appointmentId),
                child: DoctorAppointmentDetailsPage(
                  appointmentId: appointmentId,
                ),
              );
            },
          ),
        ],
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
                builder: (_, _) => BlocProvider(
                  create: (_) => GetIt.instance<MyAppointmentsCubit>()..load(),
                  child: const MyAppointmentsPage(),
                ),
                routes: [
                  GoRoute(
                    path: ':appointmentId',
                    name: appointmentDetails,
                    builder: (_, state) {
                      final appointmentId =
                          state.pathParameters['appointmentId'] ?? '';
                      return BlocProvider(
                        create: (_) =>
                            GetIt.instance<AppointmentDetailsCubit>()
                              ..load(appointmentId),
                        child: AppointmentDetailsPage(
                          appointmentId: appointmentId,
                        ),
                      );
                    },
                  ),
                ],
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
