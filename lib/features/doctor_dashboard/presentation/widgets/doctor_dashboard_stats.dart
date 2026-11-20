import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/entities/doctor_appointment_filter.dart';
import '../../domain/services/doctor_appointment_policy.dart';
import '../cubit/doctor_dashboard_state.dart';

class DoctorDashboardStats extends StatelessWidget {
  const DoctorDashboardStats({
    super.key,
    required this.state,
    required this.policy,
  });

  final DoctorDashboardLoaded state;
  final DoctorAppointmentPolicy policy;

  @override
  Widget build(BuildContext context) {
    final stats = [
      ('Today', state.todayCount(DateTime.now(), policy), Icons.today_rounded),
      (
        'Pending',
        state.statusCount(DoctorAppointmentFilter.pending),
        Icons.pending_actions_rounded,
      ),
      (
        'Confirmed',
        state.statusCount(DoctorAppointmentFilter.confirmed),
        Icons.event_available_rounded,
      ),
      (
        'Completed',
        state.statusCount(DoctorAppointmentFilter.completed),
        Icons.task_alt_rounded,
      ),
      (
        'Cancelled',
        state.statusCount(DoctorAppointmentFilter.cancelled),
        Icons.event_busy_rounded,
      ),
    ];
    final width = (MediaQuery.sizeOf(context).width - 54.w) / 2;
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: [
        for (final (label, value, icon) in stats)
          SizedBox(
            width: width,
            child: _StatCard(label: label, value: value, icon: icon),
          ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$value', style: Theme.of(context).textTheme.titleLarge),
                  Text(label, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
