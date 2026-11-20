import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/entities/appointment_category.dart';

class AppointmentEmptyState extends StatelessWidget {
  const AppointmentEmptyState({
    super.key,
    required this.category,
    this.onExplore,
  });

  final AppointmentCategory category;
  final VoidCallback? onExplore;

  @override
  Widget build(BuildContext context) {
    final message = switch (category) {
      AppointmentCategory.upcoming => 'You have no upcoming appointments.',
      AppointmentCategory.completed =>
        'Completed appointments will appear here.',
      AppointmentCategory.cancelled =>
        'Cancelled appointments will appear here.',
    };
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 44.h, horizontal: 24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 48.w,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(height: 12.h),
          Text(message, textAlign: TextAlign.center),
          if (category == AppointmentCategory.upcoming && onExplore != null) ...[
            SizedBox(height: 12.h),
            OutlinedButton(
              onPressed: onExplore,
              child: const Text('Explore doctors'),
            ),
          ],
        ],
      ),
    );
  }
}
