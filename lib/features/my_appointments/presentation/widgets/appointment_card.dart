import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/widgets/home_avatar.dart';
import '../../domain/entities/appointment_category.dart';
import '../../domain/entities/my_appointment.dart';
import 'appointment_card_meta.dart';
import 'appointment_status_label.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.category,
    required this.onTap,
  });

  final MyAppointment appointment;
  final AppointmentCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (category) {
      AppointmentCategory.upcoming => AppColors.primary,
      AppointmentCategory.completed => AppColors.secondary,
      AppointmentCategory.cancelled => AppColors.error,
    };
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      DateFormat('EEE, MMM d, y').format(
                        appointment.scheduledAt.toLocal(),
                      ),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  AppointmentStatusLabel(
                    status: appointment.status,
                    color: statusColor,
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  HomeAvatar(
                    imageUrl: appointment.doctorImageUrl,
                    radius: 26,
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
                        if (appointment.specialtyName.isNotEmpty)
                          Text(
                            appointment.specialtyName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              AppointmentCardMeta(appointment: appointment),
            ],
          ),
        ),
      ),
    );
  }

}
