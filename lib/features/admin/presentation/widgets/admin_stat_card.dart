import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';

class AdminStatCard extends StatelessWidget {
  const AdminStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.unavailableLabel,
    required this.icon,
    required this.accentColor,
    required this.localeName,
    this.isLoading = false,
  });

  final String label;
  final int? value;
  final String unavailableLabel;
  final IconData icon;
  final Color accentColor;
  final String localeName;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final valueText = value == null
        ? unavailableLabel
        : NumberFormat.decimalPattern(localeName).format(value);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Icon(icon, color: accentColor, size: 22.w),
              ),
            ),
            SizedBox(height: 16.h),
            if (isLoading)
              SizedBox(
                height: 28.h,
                width: 64.w,
                child: const Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else
              Text(
                valueText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: value == null
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            SizedBox(height: 4.h),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
