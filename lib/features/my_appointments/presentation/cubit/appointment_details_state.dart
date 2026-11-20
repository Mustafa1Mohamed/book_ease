import 'package:equatable/equatable.dart';

import '../../domain/entities/my_appointment.dart';

sealed class AppointmentDetailsState extends Equatable {
  const AppointmentDetailsState();

  @override
  List<Object?> get props => [];
}

class AppointmentDetailsInitial extends AppointmentDetailsState {
  const AppointmentDetailsInitial();
}

class AppointmentDetailsLoading extends AppointmentDetailsState {
  const AppointmentDetailsLoading();
}

class AppointmentDetailsFailure extends AppointmentDetailsState {
  const AppointmentDetailsFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class AppointmentDetailsLoaded extends AppointmentDetailsState {
  const AppointmentDetailsLoaded({
    required this.appointment,
    this.isCancelling = false,
    this.cancellationCompleted = false,
    this.errorMessage,
  });

  final MyAppointment appointment;
  final bool isCancelling;
  final bool cancellationCompleted;
  final String? errorMessage;

  AppointmentDetailsLoaded copyWith({
    MyAppointment? appointment,
    bool? isCancelling,
    bool? cancellationCompleted,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AppointmentDetailsLoaded(
      appointment: appointment ?? this.appointment,
      isCancelling: isCancelling ?? this.isCancelling,
      cancellationCompleted:
          cancellationCompleted ?? this.cancellationCompleted,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    appointment,
    isCancelling,
    cancellationCompleted,
    errorMessage,
  ];
}
