import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

class HomeErrorView extends StatelessWidget {
  const HomeErrorView({
    super.key,
    required this.message,
    required this.onRetry,
    this.onSignOut,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 44),
            SizedBox(height: 12.h),
            Text(message, textAlign: TextAlign.center),
            SizedBox(height: 16.h),
            if (onSignOut == null)
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
              )
            else
              OutlinedButton.icon(
                onPressed: onSignOut,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign out'),
              ),
          ],
        ),
      ),
    );
  }
}
