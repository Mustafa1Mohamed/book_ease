import 'package:equatable/equatable.dart';

import '../../../my_appointments/domain/entities/my_appointment.dart';

class AdminPatientAppointmentCursor extends Equatable {
  const AdminPatientAppointmentCursor({
    required this.documentId,
    required this.appointmentAt,
  });

  final String documentId;
  final DateTime appointmentAt;

  @override
  List<Object?> get props => [documentId, appointmentAt];
}

class AdminPatientAppointmentsPage extends Equatable {
  const AdminPatientAppointmentsPage({
    required this.appointments,
    required this.hasMore,
    this.nextCursor,
  });

  final List<MyAppointment> appointments;
  final bool hasMore;
  final AdminPatientAppointmentCursor? nextCursor;

  @override
  List<Object?> get props => [appointments, hasMore, nextCursor];
}
