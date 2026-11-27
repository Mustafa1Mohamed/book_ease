import '../../domain/entities/admin_patient.dart';
import '../../domain/entities/admin_patient_appointments_page.dart';
import '../../domain/entities/admin_patient_page.dart';

abstract interface class AdminPatientDataSource {
  Future<AdminPatientPage> getPatients({
    required String search,
    AdminPatientCursor? cursor,
  });

  Future<AdminPatient?> getPatient(String uid);

  Future<AdminPatientAppointmentsPage> getAppointments({
    required String patientUid,
    AdminPatientAppointmentCursor? cursor,
  });
}
