import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/upcoming_appointment.dart';
import 'home_avatar.dart';

class UpcomingAppointmentCard extends StatelessWidget {
  const UpcomingAppointmentCard({super.key, required this.appointment});

  final UpcomingAppointment appointment;

  @override
  Widget build(BuildContext context) {
    final time = appointment.timeLabel.isEmpty
        ? DateFormat.jm().format(appointment.scheduledAt)
        : appointment.timeLabel;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.event_available_rounded,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    DateFormat('EEE, MMM d').format(appointment.scheduledAt),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (appointment.status.isNotEmpty)
                  Text(
                    _capitalize(appointment.status),
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: AppColors.secondary),
                  ),
              ],
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                HomeAvatar(
                  imageUrl: appointment.doctorImageUrl,
                  radius: 24,
                  fallbackIcon: Icons.medical_services_rounded,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.doctorName.isEmpty
                            ? 'Doctor details unavailable'
                            : appointment.doctorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (appointment.specialtyName.isNotEmpty) ...[
                        SizedBox(height: 3.h),
                        Text(
                          appointment.specialtyName,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Text(time, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String value) =>
      value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';
}
