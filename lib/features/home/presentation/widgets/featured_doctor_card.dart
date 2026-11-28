import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/featured_doctor.dart';
import 'doctor_card_detail.dart';
import 'home_avatar.dart';

class FeaturedDoctorCard extends StatelessWidget {
  const FeaturedDoctorCard({super.key, required this.doctor});

  final FeaturedDoctor doctor;

  @override
  Widget build(BuildContext context) {
    final rating = doctor.rating;
    final consultationFee = doctor.consultationFee;
    final isAvailable = doctor.isAvailable;
    final specialtyName =
        Localizations.localeOf(context).languageCode == 'ar' &&
            doctor.specialtyNameAr.isNotEmpty
        ? doctor.specialtyNameAr
        : doctor.specialtyName;
    return SizedBox(
      width: 224.w,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  HomeAvatar(
                    imageUrl: doctor.imageUrl,
                    radius: 25,
                    fallbackIcon: Icons.medical_services_rounded,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      doctor.fullName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              if (specialtyName.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text(
                  specialtyName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              SizedBox(height: 12.h),
              Wrap(
                spacing: 12.w,
                runSpacing: 6.h,
                children: [
                  if (rating != null)
                    DoctorCardDetail(
                      icon: Icons.star_rounded,
                      color: AppColors.warning,
                      label: rating.toStringAsFixed(1),
                    ),
                  if (consultationFee != null)
                    DoctorCardDetail(
                      icon: Icons.payments_outlined,
                      color: AppColors.secondary,
                      label: 'Fee ${_formatFee(consultationFee)}',
                    ),
                  if (isAvailable != null)
                    DoctorCardDetail(
                      icon: Icons.circle,
                      color: isAvailable
                          ? AppColors.success
                          : AppColors.textHint,
                      label: isAvailable ? 'Available' : 'Unavailable',
                    ),
                ],
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
