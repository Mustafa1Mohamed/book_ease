import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/entities/upcoming_appointment.dart';
import 'home_section_empty.dart';
import 'home_section_header.dart';
import 'upcoming_appointment_card.dart';

class HomeUpcomingAppointmentSection extends StatelessWidget {
  const HomeUpcomingAppointmentSection({
    super.key,
    required this.appointment,
    required this.onBookAppointment,
    required this.hasError,
    required this.onRetry,
  });

  final UpcomingAppointment? appointment;
  final VoidCallback onBookAppointment;
  final bool hasError;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HomeSectionHeader(title: 'Upcoming appointment'),
        SizedBox(height: 12.h),
        if (appointment case final value?)
          UpcomingAppointmentCard(appointment: value)
        else if (!hasError) ...[
          const HomeSectionEmpty(
            message: 'You do not have an upcoming appointment.',
          ),
          SizedBox(height: 12.h),
          OutlinedButton.icon(
            onPressed: onBookAppointment,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Book an appointment'),
          ),
        ],
        if (hasError)
          HomeSectionEmpty(
            message: 'Could not load appointment data.',
            onRetry: onRetry,
          ),
      ],
    );
  }
}
