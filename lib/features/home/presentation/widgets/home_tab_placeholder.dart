import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';

class HomeTabPlaceholder extends StatelessWidget {
  const HomeTabPlaceholder({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52.w, color: AppColors.primary),
            SizedBox(height: 16.h),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
