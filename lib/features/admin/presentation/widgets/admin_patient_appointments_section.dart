import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../my_appointments/domain/entities/my_appointment.dart';
import '../cubit/admin_patient_details_state.dart';

class AdminPatientAppointmentsSection extends StatelessWidget {
  const AdminPatientAppointmentsSection({
    super.key,
    required this.state,
    required this.onRetry,
    required this.onRetryMore,
  });

  final AdminPatientDetailsState state;
  final VoidCallback onRetry;
  final VoidCallback onRetryMore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final appointments = state.appointments;
    final upcoming = appointments.where(_isUpcoming).toList();
    final completed = appointments
        .where((appointment) => appointment.status == 'completed')
        .toList();
    final cancelled = appointments
        .where(
          (appointment) =>
              appointment.status == 'cancelled' ||
              appointment.status == 'canceled',
        )
        .toList();
    final categorizedIds = {
      ...upcoming.map((appointment) => appointment.id),
      ...completed.map((appointment) => appointment.id),
      ...cancelled.map((appointment) => appointment.id),
    };
    final other = appointments
        .where((appointment) => !categorizedIds.contains(appointment.id))
        .toList();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(18.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.adminPatientAppointments,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 10.h),
            if (state.isAppointmentsLoading && appointments.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (state.appointmentsHasError && appointments.isEmpty)
              _InlineMessage(
                message: l10n.adminPatientAppointmentsError,
                actionLabel: l10n.retry,
                onPressed: onRetry,
              )
            else if (appointments.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 18.h),
                child: Text(l10n.adminPatientAppointmentsEmpty),
              )
            else ...[
              _AppointmentGroup(
                title: l10n.adminPatientUpcoming,
                appointments: upcoming,
              ),
              _AppointmentGroup(
                title: l10n.adminPatientCompleted,
                appointments: completed,
              ),
              _AppointmentGroup(
                title: l10n.adminPatientCancelled,
                appointments: cancelled,
              ),
              _AppointmentGroup(
                title: l10n.adminPatientOtherAppointments,
                appointments: other,
              ),
              if (state.isLoadingMoreAppointments)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(14),
                    child: CircularProgressIndicator(),
                  ),
                ),
              if (state.appointmentsHasError && appointments.isNotEmpty)
                _InlineMessage(
                  message: l10n.adminPatientAppointmentsError,
                  actionLabel: l10n.retry,
                  onPressed: onRetryMore,
                ),
              if (state.appointmentsHasMore &&
                  !state.isLoadingMoreAppointments &&
                  !state.appointmentsHasError)
                Center(
                  child: TextButton(
                    onPressed: onRetryMore,
                    child: Text(l10n.adminDoctorsLoadMore),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  bool _isUpcoming(MyAppointment appointment) =>
      appointment.scheduledAt.isAfter(DateTime.now()) &&
      (appointment.status == 'confirmed' ||
          appointment.status == 'pending' ||
          appointment.status == 'scheduled' ||
          appointment.status == 'booked');
}

class _AppointmentGroup extends StatelessWidget {
  const _AppointmentGroup({required this.title, required this.appointments});

  final String title;
  final List<MyAppointment> appointments;

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 12.h, bottom: 4.h),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
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
    final status = switch (appointment.status) {
      'confirmed' => l10n.adminAppointmentStatusConfirmed,
      'pending' => l10n.adminAppointmentStatusPending,
      'scheduled' => l10n.adminAppointmentStatusScheduled,
      'booked' => l10n.adminAppointmentStatusBooked,
      'completed' => l10n.adminPatientCompleted,
      'cancelled' || 'canceled' => l10n.adminPatientCancelled,
      _ => appointment.status,
    };
    final scheduledAt = DateFormat.yMMMd(l10n.localeName)
        .add_jm()
        .format(appointment.scheduledAt.toLocal());
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundImage: appointment.doctorImageUrl.isEmpty
            ? null
            : NetworkImage(appointment.doctorImageUrl),
        child: appointment.doctorImageUrl.isEmpty
            ? const Icon(Icons.medical_services_outlined)
            : null,
      ),
      title: Text(
        appointment.doctorName.isEmpty
            ? l10n.adminDoctorProfile
            : appointment.doctorName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        [
          if (appointment.specialtyName.isNotEmpty) appointment.specialtyName,
          scheduledAt,
          status,
        ].join(' · '),
      ),
      isThreeLine: true,
    );
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({
    required this.message,
    required this.actionLabel,
    required this.onPressed,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: 12.h),
    child: Row(
      children: [
        Expanded(child: Text(message)),
        TextButton(onPressed: onPressed, child: Text(actionLabel)),
      ],
    ),
  );
}
