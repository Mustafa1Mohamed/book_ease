import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/domain/entities/featured_doctor.dart';
import '../../../home/presentation/widgets/doctor_card_detail.dart';
import '../../../home/presentation/widgets/home_avatar.dart';

class ExploreDoctorCard extends StatelessWidget {
  const ExploreDoctorCard({super.key, required this.doctor});

  final FeaturedDoctor doctor;

  @override
  Widget build(BuildContext context) {
    final rating = doctor.rating;
    final fee = doctor.consultationFee;
    final availability = doctor.isAvailable;
    void openDetails() => context.pushNamed(
      AppRouter.doctorDetails,
      pathParameters: {'doctorId': doctor.id},
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: openDetails,
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(
            children: [
            HomeAvatar(
              imageUrl: doctor.imageUrl,
              radius: 30,
              fallbackIcon: Icons.medical_services_rounded,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (doctor.specialtyName.isNotEmpty) ...[
                    SizedBox(height: 3.h),
                    Text(
                      doctor.specialtyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 10.w,
                    runSpacing: 4.h,
                    children: [
                      if (rating != null)
                        DoctorCardDetail(
                          icon: Icons.star_rounded,
                          color: AppColors.warning,
                          label: rating.toStringAsFixed(1),
                        ),
                      if (fee != null)
                        DoctorCardDetail(
                          icon: Icons.payments_outlined,
                          color: AppColors.secondary,
                          label: 'Fee ${_formatFee(fee)}',
                        ),
                      if (availability != null)
                        DoctorCardDetail(
                          icon: Icons.circle,
                          color: availability
                              ? AppColors.success
                              : AppColors.textHint,
                          label: availability ? 'Available' : 'Unavailable',
                        ),
                    ],
                  ),
                ],
              ),
            ),
              Icon(
                Icons.chevron_right_rounded,
                semanticLabel: 'View ${doctor.fullName} details',
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatFee(double fee) =>
      fee == fee.roundToDouble() ? fee.toStringAsFixed(0) : fee.toString();
}
