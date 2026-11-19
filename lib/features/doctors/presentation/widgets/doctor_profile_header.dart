import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../home/domain/entities/featured_doctor.dart';
import '../../../home/presentation/widgets/doctor_card_detail.dart';
import '../../../home/presentation/widgets/home_avatar.dart';

class DoctorProfileHeader extends StatelessWidget {
  const DoctorProfileHeader({super.key, required this.doctor});

  final FeaturedDoctor doctor;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(18.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeAvatar(
              imageUrl: doctor.imageUrl,
              radius: 42,
              fallbackIcon: Icons.medical_services_rounded,
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.fullName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (doctor.specialtyName.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      doctor.specialtyName,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 12.w,
                    runSpacing: 6.h,
                    children: [
                      if (doctor.rating != null)
                        DoctorCardDetail(
                          icon: Icons.star_rounded,
                          color: AppColors.warning,
                          label: _ratingLabel(),
                        ),
                      if (doctor.isAvailable != null)
                        DoctorCardDetail(
                          icon: Icons.circle,
                          color: doctor.isAvailable!
                              ? AppColors.success
                              : AppColors.textHint,
                          label: doctor.isAvailable!
                              ? 'Available'
                              : 'Unavailable',
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _ratingLabel() {
    final rating = doctor.rating;
    if (rating == null) return '';
    final count = doctor.reviewCount;
    return count == null
        ? rating.toStringAsFixed(1)
        : '${rating.toStringAsFixed(1)} ($count reviews)';
  }
}
