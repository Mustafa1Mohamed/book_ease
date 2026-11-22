import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() => _hasError = false);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    try {
      final preferences = GetIt.instance<SharedPreferences>();
      final onboardingComplete =
          preferences.getBool(AppRouter.onboardingCompleteKey) ?? false;
      if (!onboardingComplete) {
        context.goNamed(AppRouter.onboarding);
        return;
      }

      final authCubit = context.read<AuthCubit>();
      await authCubit.checkSession();
      if (!mounted) return;

      final authState = authCubit.state;
      if (authState is AuthUnauthenticated) {
        context.goNamed(AppRouter.login);
        return;
      }
      if (authState is AuthProfileIncomplete) {
        context.goNamed(AppRouter.profileComplete);
        return;
      }
      if (authState is AuthAuthenticated) {
        context.goNamed(AppRouter.home);
        return;
      }
      throw StateError(
        authState is AuthError
            ? authState.message
            : 'Authentication state could not be restored.',
      );
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FAFF), AppColors.primaryLight],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 104.w,
                height: 104.w,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(28.r),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A2563EB),
                      blurRadius: 24,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_hospital_rounded,
                  size: 58,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'BookEase',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              SizedBox(height: 8.h),
              Text(
                'Healthcare made simple',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              if (_hasError) ...[
                const Text(
                  'We could not start the app.',
                  style: TextStyle(color: AppColors.error),
                ),
                SizedBox(height: 12.h),
                ElevatedButton(
                  onPressed: _initialize,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(180.w, 48.h),
                  ),
                  child: const Text('Try Again'),
                ),
              ] else
                const CircularProgressIndicator(strokeWidth: 2.5),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}
