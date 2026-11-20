import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../features/home/presentation/widgets/home_avatar.dart';
import '../../../my_appointments/domain/entities/my_appointment.dart';

class DoctorAppointmentCard extends StatelessWidget {
  const DoctorAppointmentCard({
    super.key,
    required this.appointment,
    required this.onTap,
  });

  final MyAppointment appointment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final time = appointment.timeLabel.isNotEmpty
        ? appointment.timeLabel
        : DateFormat.jm().format(appointment.scheduledAt.toLocal());
    final status = appointment.status.isEmpty
        ? 'Scheduled'
        : appointment.status.replaceAll('_', ' ');
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(
            children: [
              SizedBox(
                width: 58.w,
                child: Column(
                  children: [
                    Text(time, style: Theme.of(context).textTheme.titleSmall),
                    if (appointment.endAt != null)
                      Text(
                        DateFormat.jm().format(
                          appointment.endAt!.toLocal(),
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              HomeAvatar(
                imageUrl: appointment.patientImageUrl,
                radius: 24,
                fallbackIcon: Icons.person_rounded,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.patientName.isEmpty
                          ? 'Patient details unavailable'
                          : appointment.patientName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      status,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
