import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_router.dart';
import '../../domain/entities/doctor_appointment_filter.dart';
import '../../domain/services/doctor_appointment_policy.dart';
import '../cubit/doctor_dashboard_cubit.dart';
import '../cubit/doctor_dashboard_state.dart';
import 'doctor_appointment_card.dart';
import 'doctor_appointment_filter_chips.dart';
import 'doctor_dashboard_stats.dart';
import 'doctor_schedule_date_header.dart';
import 'doctor_welcome_header.dart';

class DoctorDashboardContent extends StatelessWidget {
  const DoctorDashboardContent({super.key, required this.state});

  final DoctorDashboardLoaded state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DoctorDashboardCubit>();
    final policy = const DoctorAppointmentPolicy();
    final counts = {
      for (final filter in DoctorAppointmentFilter.values)
        filter: state.statusCount(filter),
    };
    final upcoming = state
        .upcomingAppointments(DateTime.now(), policy)
        .take(3)
        .toList();
    final daily = state.appointmentsForSelectedDate();
    return RefreshIndicator(
      onRefresh: cubit.refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 28.h),
        children: [
          if (state.refreshError != null)
            _RefreshError(message: state.refreshError!),
          DoctorWelcomeHeader(doctor: state.data.doctor),
          Text('Overview', style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 10.h),
          DoctorDashboardStats(state: state, policy: policy),
          SizedBox(height: 22.h),
          Text(
            'Upcoming appointments',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8.h),
          if (upcoming.isEmpty)
            const _SectionEmpty(message: 'No upcoming appointments.')
          else
            for (final appointment in upcoming) ...[
              DoctorAppointmentCard(
                appointment: appointment,
                onTap: () => _openAppointment(context, appointment.id),
              ),
              SizedBox(height: 8.h),
            ],
          SizedBox(height: 16.h),
          Text('Daily schedule', style: Theme.of(context).textTheme.titleLarge),
          DoctorScheduleDateHeader(
            selectedDate: state.selectedDate,
            onDateSelected: cubit.selectDate,
          ),
          DoctorAppointmentFilterChips(
            selected: state.filter,
            counts: counts,
            onSelected: cubit.selectFilter,
          ),
          SizedBox(height: 10.h),
          if (daily.isEmpty)
            const _SectionEmpty(message: 'No appointments for this date.')
          else
            for (final appointment in daily) ...[
              DoctorAppointmentCard(
                appointment: appointment,
                onTap: () => _openAppointment(context, appointment.id),
              ),
              SizedBox(height: 8.h),
            ],
        ],
      ),
    );
  }

  Future<void> _openAppointment(
    BuildContext context,
    String appointmentId,
  ) async {
    final updated = await context.pushNamed<bool>(
      AppRouter.doctorAppointmentDetails,
      pathParameters: {'appointmentId': appointmentId},
    );
    if (updated == true && context.mounted) {
      await context.read<DoctorDashboardCubit>().refresh();
    }
  }
}

class _SectionEmpty extends StatelessWidget {
  const _SectionEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: 18.h),
    child: Text(message, textAlign: TextAlign.center),
  );
}

class _RefreshError extends StatelessWidget {
  const _RefreshError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: 12.h),
    child: Text(
      message,
      style: TextStyle(color: Theme.of(context).colorScheme.error),
    ),
  );
}
