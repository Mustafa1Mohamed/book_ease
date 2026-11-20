import 'package:equatable/equatable.dart';

import '../../../my_appointments/domain/entities/my_appointment.dart';
import '../../domain/entities/doctor_appointment_filter.dart';
import '../../domain/entities/doctor_dashboard_data.dart';
import '../../domain/services/doctor_appointment_policy.dart';

sealed class DoctorDashboardState extends Equatable {
  const DoctorDashboardState();

  @override
  List<Object?> get props => [];
}

class DoctorDashboardInitial extends DoctorDashboardState {
  const DoctorDashboardInitial();
}

class DoctorDashboardLoading extends DoctorDashboardState {
  const DoctorDashboardLoading();
}

class DoctorDashboardFailure extends DoctorDashboardState {
  const DoctorDashboardFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class DoctorDashboardLoaded extends DoctorDashboardState {
  const DoctorDashboardLoaded({
    required this.data,
    required this.selectedDate,
    this.filter = DoctorAppointmentFilter.all,
    this.isRefreshing = false,
    this.refreshError,
  });

  final DoctorDashboardData data;
  final DateTime selectedDate;
  final DoctorAppointmentFilter filter;
  final bool isRefreshing;
  final String? refreshError;

  int todayCount(DateTime now, DoctorAppointmentPolicy policy) =>
      policy.todayCount(data.appointments, now);

  int statusCount(DoctorAppointmentFilter status) => data.appointments
      .where((appointment) => status.matches(appointment.status))
      .length;

  List<MyAppointment> appointmentsForSelectedDate() {
    final selected = selectedDate.toLocal();
    final result = data.appointments
        .where((appointment) {
          final scheduled = appointment.scheduledAt.toLocal();
          return scheduled.year == selected.year &&
              scheduled.month == selected.month &&
              scheduled.day == selected.day &&
              filter.matches(appointment.status);
        })
        .toList()
      ..sort((first, second) => first.scheduledAt.compareTo(second.scheduledAt));
    return result;
  }

  List<MyAppointment> upcomingAppointments(
    DateTime now,
    DoctorAppointmentPolicy policy,
  ) {
    return data.appointments
        .where((appointment) => policy.isUpcoming(appointment, now))
        .toList()
      ..sort((first, second) => first.scheduledAt.compareTo(second.scheduledAt));
  }

  DoctorDashboardLoaded copyWith({
    DoctorDashboardData? data,
    DateTime? selectedDate,
    DoctorAppointmentFilter? filter,
    bool? isRefreshing,
    String? refreshError,
    bool clearRefreshError = false,
  }) {
    return DoctorDashboardLoaded(
      data: data ?? this.data,
      selectedDate: selectedDate ?? this.selectedDate,
      filter: filter ?? this.filter,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      refreshError: clearRefreshError ? null : refreshError ?? this.refreshError,
    );
  }

  @override
  List<Object?> get props => [
    data,
    selectedDate,
    filter,
    isRefreshing,
    refreshError,
  ];
}
