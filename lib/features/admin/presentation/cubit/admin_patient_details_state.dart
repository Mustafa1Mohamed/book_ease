import 'package:equatable/equatable.dart';

import '../../../my_appointments/domain/entities/my_appointment.dart';
import '../../domain/entities/admin_patient.dart';
import '../../domain/entities/admin_patient_appointments_page.dart';

class AdminPatientDetailsState extends Equatable {
  const AdminPatientDetailsState({
    this.patient,
    this.appointments = const [],
    this.appointmentCursor,
    this.appointmentsHasMore = false,
    this.isLoading = false,
    this.isAppointmentsLoading = false,
    this.isLoadingMoreAppointments = false,
    this.hasError = false,
    this.appointmentsHasError = false,
  });

  final AdminPatient? patient;
  final List<MyAppointment> appointments;
  final AdminPatientAppointmentCursor? appointmentCursor;
  final bool appointmentsHasMore;
  final bool isLoading;
  final bool isAppointmentsLoading;
  final bool isLoadingMoreAppointments;
  final bool hasError;
  final bool appointmentsHasError;

  AdminPatientDetailsState copyWith({
    AdminPatient? patient,
    bool clearPatient = false,
    List<MyAppointment>? appointments,
    AdminPatientAppointmentCursor? appointmentCursor,
    bool clearAppointmentCursor = false,
    bool? appointmentsHasMore,
    bool? isLoading,
    bool? isAppointmentsLoading,
    bool? isLoadingMoreAppointments,
    bool? hasError,
    bool? appointmentsHasError,
  }) => AdminPatientDetailsState(
    patient: clearPatient ? null : patient ?? this.patient,
    appointments: appointments ?? this.appointments,
    appointmentCursor: clearAppointmentCursor
        ? null
        : appointmentCursor ?? this.appointmentCursor,
    appointmentsHasMore: appointmentsHasMore ?? this.appointmentsHasMore,
    isLoading: isLoading ?? this.isLoading,
    isAppointmentsLoading: isAppointmentsLoading ?? this.isAppointmentsLoading,
    isLoadingMoreAppointments:
        isLoadingMoreAppointments ?? this.isLoadingMoreAppointments,
    hasError: hasError ?? this.hasError,
    appointmentsHasError: appointmentsHasError ?? this.appointmentsHasError,
  );

  @override
  List<Object?> get props => [
    patient,
    appointments,
    appointmentCursor,
    appointmentsHasMore,
    isLoading,
    isAppointmentsLoading,
    isLoadingMoreAppointments,
    hasError,
    appointmentsHasError,
  ];
}
