import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_router.dart';
import '../../domain/entities/appointment_category.dart';
import '../../domain/entities/my_appointment.dart';
import 'appointment_card.dart';
import 'appointment_empty_state.dart';

class AppointmentsList extends StatelessWidget {
  const AppointmentsList({
    super.key,
    required this.appointments,
    required this.category,
    required this.refreshError,
    required this.onOpen,
  });

  final List<MyAppointment> appointments;
  final AppointmentCategory category;
  final String? refreshError;
  final ValueChanged<MyAppointment> onOpen;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 20.h),
      children: [
        if (refreshError != null) _RefreshError(message: refreshError!),
        if (appointments.isEmpty)
          AppointmentEmptyState(
            category: category,
            onExplore: category == AppointmentCategory.upcoming
                ? () => context.goNamed(AppRouter.explore)
                : null,
          )
        else
          for (final appointment in appointments) ...[
            AppointmentCard(
              appointment: appointment,
              category: category,
              onTap: () => onOpen(appointment),
            ),
            SizedBox(height: 10.h),
          ],
      ],
    );
  }
}

class _RefreshError extends StatelessWidget {
  const _RefreshError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        message,
        style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
      ),
    );
  }
}
