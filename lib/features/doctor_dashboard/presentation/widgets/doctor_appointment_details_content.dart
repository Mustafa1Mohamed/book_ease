import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../my_appointments/domain/entities/my_appointment.dart';
import '../../../my_appointments/presentation/widgets/appointment_info_row.dart';
import '../../../home/presentation/widgets/home_avatar.dart';

class DoctorAppointmentDetailsContent extends StatelessWidget {
  const DoctorAppointmentDetailsContent({
    super.key,
    required this.appointment,
    required this.canComplete,
    required this.isUpdating,
    required this.errorMessage,
    required this.onComplete,
  });

  final MyAppointment appointment;
  final bool canComplete;
  final bool isUpdating;
  final String? errorMessage;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final date = appointment.scheduledAt.toLocal();
    final time = appointment.timeLabel.isEmpty
        ? DateFormat.jm().format(date)
        : appointment.timeLabel;
    return ListView(
      padding: EdgeInsets.all(18.w),
      children: [
        _PatientHeader(appointment: appointment),
        SizedBox(height: 18.h),
        Text(
          'Appointment information',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        AppointmentInfoRow(
          icon: Icons.calendar_month_rounded,
          label: 'Date',
          value: DateFormat.yMMMMEEEEd().format(date),
        ),
        AppointmentInfoRow(
          icon: Icons.schedule_rounded,
          label: 'Time',
          value: time,
        ),
        AppointmentInfoRow(
          icon: Icons.info_outline_rounded,
          label: 'Status',
          value: _formatStatus(appointment.status),
        ),
        if (appointment.consultationType.isNotEmpty)
          AppointmentInfoRow(
            icon: Icons.medical_services_outlined,
            label: 'Consultation',
            value: appointment.consultationType,
          ),
        if (appointment.createdAt != null)
          AppointmentInfoRow(
            icon: Icons.event_note_rounded,
            label: 'Booked on',
            value: DateFormat.yMMMd().format(appointment.createdAt!.toLocal()),
          ),
        AppointmentInfoRow(
          icon: Icons.confirmation_number_outlined,
          label: 'Reference',
          value: appointment.id,
        ),
        if (errorMessage != null) ...[
          SizedBox(height: 12.h),
          Text(
            errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        if (canComplete) ...[
          SizedBox(height: 18.h),
          OutlinedButton.icon(
            onPressed: isUpdating ? null : () => _confirm(context),
            icon: isUpdating
                ? SizedBox(
                    width: 18.w,
                    height: 18.w,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.task_alt_rounded),
            label: Text(isUpdating ? 'Updating...' : 'Mark completed'),
          ),
        ],
      ],
    );
  }

  Future<void> _confirm(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Complete this appointment?'),
        content: const Text(
          'This will mark the appointment as completed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Not yet'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Mark completed'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) onComplete();
  }

  String _formatStatus(String status) {
    if (status.isEmpty) return 'Scheduled';
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}

class _PatientHeader extends StatelessWidget {
  const _PatientHeader({required this.appointment});

  final MyAppointment appointment;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            HomeAvatar(
              imageUrl: appointment.patientImageUrl,
              fallbackIcon: Icons.person_rounded,
              radius: 32,
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment.patientName.isEmpty
                        ? 'Patient details unavailable'
                        : appointment.patientName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (appointment.patientPhoneNumber.isNotEmpty)
                    Text(appointment.patientPhoneNumber),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
