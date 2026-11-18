import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/data/datasources/auth_remote_data_source.dart';

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

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        context.goNamed(AppRouter.login);
        return;
      }

      final profile = await GetIt.instance<AuthRemoteDataSource>().getProfile(
        currentUser.uid,
      );
      if (!mounted) return;
      if (profile == null || !profile.isComplete) {
        context.goNamed(AppRouter.profileComplete);
      } else {
        context.goNamed(AppRouter.home);
      }
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
