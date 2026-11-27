import '../entities/admin_patient.dart';
import '../entities/admin_patient_appointments_page.dart';
import '../entities/admin_patient_page.dart';

abstract interface class AdminPatientRepository {
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
