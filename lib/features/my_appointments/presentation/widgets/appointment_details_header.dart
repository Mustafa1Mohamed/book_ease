import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/widgets/home_avatar.dart';
import '../../domain/entities/my_appointment.dart';

class AppointmentDetailsHeader extends StatelessWidget {
  const AppointmentDetailsHeader({super.key, required this.appointment});

  final MyAppointment appointment;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            HomeAvatar(
              imageUrl: appointment.doctorImageUrl,
              radius: 34,
              fallbackIcon: Icons.medical_services_rounded,
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment.doctorName.isEmpty
                        ? 'Doctor details unavailable'
                        : appointment.doctorName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (appointment.specialtyName.isNotEmpty)
                    Text(appointment.specialtyName),
                ],
              ),
            ),
            Icon(Icons.circle, size: 10, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
