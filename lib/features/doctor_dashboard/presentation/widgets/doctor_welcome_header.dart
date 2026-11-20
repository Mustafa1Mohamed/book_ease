import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../../home/presentation/widgets/home_avatar.dart';
import '../../../home/domain/entities/featured_doctor.dart';

class DoctorWelcomeHeader extends StatelessWidget {
  const DoctorWelcomeHeader({super.key, required this.doctor});

  final FeaturedDoctor doctor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          HomeAvatar(
            imageUrl: doctor.imageUrl,
            fallbackIcon: Icons.medical_services_rounded,
            radius: 26,
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
                if (doctor.specialtyName.isNotEmpty)
                  Text(
                    doctor.specialtyName,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
