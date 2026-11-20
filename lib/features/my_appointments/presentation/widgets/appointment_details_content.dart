import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/entities/my_appointment.dart';
import 'appointment_booking_information.dart';
import 'appointment_cancellation_button.dart';
import 'appointment_details_header.dart';
import 'appointment_info_row.dart';
import 'appointment_status_label.dart';

class AppointmentDetailsContent extends StatelessWidget {
  const AppointmentDetailsContent({
    super.key,
    required this.appointment,
    required this.isCancelling,
    required this.canCancel,
    required this.cancellationError,
    required this.policyDescription,
    required this.onCancel,
  });

  final MyAppointment appointment;
  final bool isCancelling;
  final bool canCancel;
  final String? cancellationError;
  final String policyDescription;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final start = appointment.timeLabel.isEmpty
        ? DateFormat.jm().format(appointment.scheduledAt.toLocal())
        : appointment.timeLabel;
    final time = appointment.endAt == null
        ? start
        : '$start – ${DateFormat.jm().format(appointment.endAt!.toLocal())}';
    return ListView(
      padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 28.h),
      children: [
        AppointmentDetailsHeader(appointment: appointment),
        SizedBox(height: 18.h),
        Text(
          'Appointment information',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 8.h),
        AppointmentInfoRow(
          icon: Icons.calendar_month_rounded,
          label: 'Date',
          value: DateFormat.yMMMMEEEEd().format(
            appointment.scheduledAt.toLocal(),
          ),
        ),
        AppointmentInfoRow(
          icon: Icons.schedule_rounded,
          label: 'Time',
          value: time,
        ),
        AppointmentInfoRow(
          icon: Icons.info_outline_rounded,
          label: 'Status',
          value: formatAppointmentStatus(appointment.status),
        ),
        if (appointment.consultationType.isNotEmpty)
          AppointmentInfoRow(
            icon: Icons.medical_services_outlined,
            label: 'Consultation',
            value: appointment.consultationType,
          ),
        if (appointment.consultationDurationMinutes != null)
          AppointmentInfoRow(
            icon: Icons.timelapse_rounded,
            label: 'Duration',
            value: '${appointment.consultationDurationMinutes} minutes',
          ),
        if (appointment.clinicName.isNotEmpty)
          AppointmentInfoRow(
            icon: Icons.local_hospital_outlined,
            label: 'Clinic',
            value: appointment.clinicName,
          ),
        if (appointment.clinicAddress.isNotEmpty)
          AppointmentInfoRow(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: appointment.clinicAddress,
          ),
        if (appointment.consultationFee != null)
          AppointmentInfoRow(
            icon: Icons.payments_outlined,
            label: 'Consultation fee',
            value: _formatFee(appointment.consultationFee!),
          ),
        SizedBox(height: 12.h),
        AppointmentBookingInformation(appointment: appointment),
        if (cancellationError case final error?) ...[
          SizedBox(height: 12.h),
          Text(
            error,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ],
        if (canCancel) ...[
          SizedBox(height: 18.h),
          AppointmentCancellationButton(
            appointment: appointment,
            isCancelling: isCancelling,
            policyDescription: policyDescription,
            onCancel: onCancel,
          ),
        ],
      ],
    );
  }

  String _formatFee(double fee) =>
      fee == fee.roundToDouble() ? fee.toStringAsFixed(0) : fee.toString();
}
