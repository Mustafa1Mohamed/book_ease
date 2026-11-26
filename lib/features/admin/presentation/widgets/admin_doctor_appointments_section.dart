import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../my_appointments/domain/entities/my_appointment.dart';

class AdminDoctorAppointmentsSection extends StatelessWidget {
  const AdminDoctorAppointmentsSection({
    super.key,
    required this.appointments,
    required this.unavailable,
  });

  final List<MyAppointment> appointments;
  final bool unavailable;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.adminDoctorAppointments,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        if (unavailable)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            child: Text(l10n.adminDoctorAppointmentsUnavailable),
          )
        else if (appointments.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            child: Text(l10n.adminDoctorNoAppointments),
          )
        else
          for (final appointment in appointments)
            _AppointmentTile(appointment: appointment),
      ],
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  const _AppointmentTile({required this.appointment});

  final MyAppointment appointment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final date = DateFormat.yMMMd(l10n.localeName)
        .add_jm()
        .format(appointment.scheduledAt.toLocal());
    final status = switch (appointment.status.trim().toLowerCase()) {
      'confirmed' => l10n.adminAppointmentStatusConfirmed,
      'pending' => l10n.adminAppointmentStatusPending,
      'scheduled' => l10n.adminAppointmentStatusScheduled,
      'booked' => l10n.adminAppointmentStatusBooked,
      _ => appointment.status,
    };
    return Card(
      child: ListTile(
        leading: const Icon(Icons.event_available_rounded),
        title: Text(
          appointment.patientName.isEmpty
              ? l10n.adminDoctorAppointments
              : appointment.patientName,
        ),
        subtitle: Text('$date • $status'),
      ),
    );
  }
}
