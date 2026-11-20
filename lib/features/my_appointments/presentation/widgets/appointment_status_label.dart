import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

String formatAppointmentStatus(String status) {
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

class AppointmentStatusLabel extends StatelessWidget {
  const AppointmentStatusLabel({
    super.key,
    required this.status,
    required this.color,
  });

  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        formatAppointmentStatus(status),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}
