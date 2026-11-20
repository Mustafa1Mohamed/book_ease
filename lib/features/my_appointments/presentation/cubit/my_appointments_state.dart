import 'package:equatable/equatable.dart';

import '../../domain/entities/appointment_category.dart';
import '../../domain/entities/my_appointment.dart';
import '../../domain/services/appointment_category_policy.dart';

sealed class MyAppointmentsState extends Equatable {
  const MyAppointmentsState();

  @override
  List<Object?> get props => [];
}

class MyAppointmentsInitial extends MyAppointmentsState {
  const MyAppointmentsInitial();
}

class MyAppointmentsLoading extends MyAppointmentsState {
  const MyAppointmentsLoading();
}

class MyAppointmentsFailure extends MyAppointmentsState {
  const MyAppointmentsFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class MyAppointmentsLoaded extends MyAppointmentsState {
  const MyAppointmentsLoaded({
    required this.appointments,
    this.selectedCategory = AppointmentCategory.upcoming,
    this.isRefreshing = false,
    this.refreshError,
  });

  final List<MyAppointment> appointments;
  final AppointmentCategory selectedCategory;
  final bool isRefreshing;
  final String? refreshError;

  List<MyAppointment> appointmentsFor(
    AppointmentCategory category,
    DateTime now,
    AppointmentCategoryPolicy policy,
  ) {
    final result = appointments
        .where((appointment) => policy.categoryOf(appointment, now) == category)
        .toList();
    result.sort(
      (first, second) => category == AppointmentCategory.upcoming
          ? first.scheduledAt.compareTo(second.scheduledAt)
          : second.scheduledAt.compareTo(first.scheduledAt),
    );
    return result;
  }

  MyAppointmentsLoaded copyWith({
    List<MyAppointment>? appointments,
    AppointmentCategory? selectedCategory,
    bool? isRefreshing,
    String? refreshError,
    bool clearRefreshError = false,
  }) {
    return MyAppointmentsLoaded(
      appointments: appointments ?? this.appointments,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      refreshError: clearRefreshError
          ? null
          : refreshError ?? this.refreshError,
    );
  }

  @override
  List<Object?> get props => [
    appointments,
    selectedCategory,
    isRefreshing,
    refreshError,
  ];
}
