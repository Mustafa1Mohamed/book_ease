import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;
  bool _navigating = false;

  static const _pages = [
    (
      title: 'Find the Right Doctor',
      description: 'Discover trusted doctors and specialists based on your healthcare needs.',
      icon: Icons.medical_services_rounded,
      color: AppColors.primary,
    ),
    (
      title: 'Book Appointments Easily',
      description: 'Choose your preferred doctor, date, and available time slot in just a few steps.',
      icon: Icons.calendar_month_rounded,
      color: AppColors.secondary,
    ),
    (
      title: 'Your Healthcare, Organized',
      description: 'Keep track of your appointments and manage your bookings in one convenient place.',
      icon: Icons.dashboard_rounded,
      color: AppColors.primaryDark,
    ),
  ];

  Future<void> _finish() async {
    if (_navigating) return;
    _navigating = true;
    await GetIt.instance<SharedPreferences>().setBool(
      AppRouter.onboardingCompleteKey,
      true,
    );
    if (mounted) context.goNamed(AppRouter.login);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
                child: _index < 2
                    ? TextButton(onPressed: _finish, child: const Text('Skip'))
                    : const SizedBox(height: 48),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (value) => setState(() => _index = value),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.sizeOf(context).height * 0.62,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 220.w,
                            height: 220.w,
                            decoration: BoxDecoration(
                              color: page.color.withValues(alpha: 0.10),
                              shape: BoxShape.circle,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 150.w,
                                  height: 150.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(36.r),
                                    border: Border.all(
                                      color: page.color.withValues(alpha: 0.18),
                                      width: 2,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x140F172A),
                                        blurRadius: 28,
                                        offset: Offset(0, 12),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    page.icon,
                                    size: 74,
                                    color: page.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 32.h),
                          Text(
                            page.title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            page.description,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 24.h),
              child: Row(
                children: [
                  if (_index > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _controller.previousPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(0, 52.h),
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                  if (_index > 0) SizedBox(width: 12.w),
                  Expanded(
                    flex: _index == 0 ? 1 : 2,
                    child: ElevatedButton(
                      onPressed: _index == 2
                          ? _finish
                          : () => _controller.nextPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                            ),
                      child: Text(_index == 2 ? 'Get Started' : 'Next'),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    width: _index == index ? 22.w : 8.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: _index == index
                          ? AppColors.primary
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
