import 'package:equatable/equatable.dart';

import '../../../my_appointments/domain/entities/my_appointment.dart';

sealed class DoctorAppointmentDetailsState extends Equatable {
  const DoctorAppointmentDetailsState();

  @override
  List<Object?> get props => [];
}

class DoctorAppointmentDetailsInitial extends DoctorAppointmentDetailsState {
  const DoctorAppointmentDetailsInitial();
}

class DoctorAppointmentDetailsLoading extends DoctorAppointmentDetailsState {
  const DoctorAppointmentDetailsLoading();
}

class DoctorAppointmentDetailsFailure extends DoctorAppointmentDetailsState {
  const DoctorAppointmentDetailsFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class DoctorAppointmentDetailsLoaded extends DoctorAppointmentDetailsState {
  const DoctorAppointmentDetailsLoaded({
    required this.appointment,
    this.isUpdating = false,
    this.completionCompleted = false,
    this.errorMessage,
  });

  final MyAppointment appointment;
  final bool isUpdating;
  final bool completionCompleted;
  final String? errorMessage;

  DoctorAppointmentDetailsLoaded copyWith({
    MyAppointment? appointment,
    bool? isUpdating,
    bool? completionCompleted,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DoctorAppointmentDetailsLoaded(
      appointment: appointment ?? this.appointment,
      isUpdating: isUpdating ?? this.isUpdating,
      completionCompleted: completionCompleted ?? this.completionCompleted,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    appointment,
    isUpdating,
    completionCompleted,
    errorMessage,
  ];
}
