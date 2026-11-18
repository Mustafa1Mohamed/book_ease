import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/patient_profile.dart';
import 'home_avatar.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.profile,
    required this.onNotificationsTap,
  });

  final PatientProfile profile;
  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
        ? 'Good afternoon'
        : 'Good evening';

    return Row(
      children: [
        HomeAvatar(imageUrl: profile.imageUrl, radius: 25),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: AppColors.textSecondary),
              ),
              SizedBox(height: 2.h),
              Text(
                profile.fullName.isEmpty
                    ? 'Welcome to BookEase'
                    : profile.fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Notifications',
          onPressed: onNotificationsTap,
          icon: const Icon(Icons.notifications_none_rounded),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
