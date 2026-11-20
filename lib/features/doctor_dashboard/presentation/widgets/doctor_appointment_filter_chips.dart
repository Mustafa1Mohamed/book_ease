import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/entities/doctor_appointment_filter.dart';

class DoctorAppointmentFilterChips extends StatelessWidget {
  const DoctorAppointmentFilterChips({
    super.key,
    required this.selected,
    required this.counts,
    required this.onSelected,
  });

  final DoctorAppointmentFilter selected;
  final Map<DoctorAppointmentFilter, int> counts;
  final ValueChanged<DoctorAppointmentFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in DoctorAppointmentFilter.values) ...[
            ChoiceChip(
              label: Text('${filter.label} (${counts[filter] ?? 0})'),
              selected: selected == filter,
              onSelected: (_) => onSelected(filter),
            ),
            SizedBox(width: 8.w),
          ],
        ],
      ),
    );
  }
}
