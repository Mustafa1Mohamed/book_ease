import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/entities/appointment_category.dart';

class AppointmentCategorySelector extends StatelessWidget {
  const AppointmentCategorySelector({
    super.key,
    required this.selected,
    required this.counts,
    required this.onSelected,
  });

  final AppointmentCategory selected;
  final Map<AppointmentCategory, int> counts;
  final ValueChanged<AppointmentCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final category in AppointmentCategory.values) ...[
            ChoiceChip(
              label: Text('${category.label} (${counts[category] ?? 0})'),
              selected: selected == category,
              onSelected: (_) => onSelected(category),
            ),
            SizedBox(width: 8.w),
          ],
        ],
      ),
    );
  }
}
