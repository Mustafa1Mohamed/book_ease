import '../../../my_appointments/domain/entities/my_appointment.dart';
import 'admin_doctor_audit_event.dart';
import 'admin_doctor.dart';

class AdminDoctorDetails {
  const AdminDoctorDetails({
    required this.doctor,
    required this.upcomingAppointments,
    this.upcomingAppointmentsUnavailable = false,
  });

  final AdminDoctor doctor;
  final List<MyAppointment> upcomingAppointments;
  final bool upcomingAppointmentsUnavailable;
}

class AdminDoctorAuditCursor {
  const AdminDoctorAuditCursor({
    required this.documentId,
    required this.createdAt,
  });

  final String documentId;
  final DateTime createdAt;
}

class AdminDoctorAuditPage {
  const AdminDoctorAuditPage({
    required this.events,
    required this.hasMore,
    this.nextCursor,
  });

  final List<AdminDoctorAuditEvent> events;
  final bool hasMore;
  final AdminDoctorAuditCursor? nextCursor;
}
