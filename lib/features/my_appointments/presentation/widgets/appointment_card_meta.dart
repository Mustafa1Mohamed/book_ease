import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/my_appointment.dart';

class AppointmentCardMeta extends StatelessWidget {
  const AppointmentCardMeta({super.key, required this.appointment});

  final MyAppointment appointment;

  @override
  Widget build(BuildContext context) {
    final start = appointment.timeLabel.isEmpty
        ? DateFormat.jm().format(appointment.scheduledAt.toLocal())
        : appointment.timeLabel;
    final time = appointment.endAt == null
        ? start
        : '$start – ${DateFormat.jm().format(appointment.endAt!.toLocal())}';
    final location = appointment.clinicName.isNotEmpty
        ? appointment.clinicName
        : appointment.clinicAddress;
    return Wrap(
      spacing: 14.w,
      runSpacing: 6.h,
      children: [
        _MetaItem(icon: Icons.schedule_rounded, label: time),
        if (appointment.consultationType.isNotEmpty)
          _MetaItem(
            icon: Icons.medical_services_outlined,
            label: appointment.consultationType,
          ),
        if (location.isNotEmpty)
          _MetaItem(icon: Icons.location_on_outlined, label: location),
      ],
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.textSecondary),
        SizedBox(width: 4.w),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 180.w),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
