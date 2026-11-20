import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/entities/my_appointment.dart';
import 'appointment_info_row.dart';

class AppointmentBookingInformation extends StatelessWidget {
  const AppointmentBookingInformation({super.key, required this.appointment});

  final MyAppointment appointment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Booking information',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 6.h),
        AppointmentInfoRow(
          icon: Icons.confirmation_number_outlined,
          label: 'Reference',
          value: appointment.id,
        ),
        if (appointment.createdAt != null)
          AppointmentInfoRow(
            icon: Icons.event_note_rounded,
            label: 'Booked on',
            value: DateFormat.yMMMd().format(appointment.createdAt!.toLocal()),
          ),
      ],
    );
  }
}
