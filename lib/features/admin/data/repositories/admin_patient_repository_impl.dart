import '../../domain/entities/admin_patient.dart';
import '../../domain/entities/admin_patient_appointments_page.dart';
import '../../domain/entities/admin_patient_page.dart';
import '../../domain/repositories/admin_patient_repository.dart';
import '../datasources/admin_patient_data_source.dart';

class AdminPatientRepositoryImpl implements AdminPatientRepository {
  const AdminPatientRepositoryImpl(this._dataSource);

  final AdminPatientDataSource _dataSource;

  @override
  Future<AdminPatientPage> getPatients({
    required String search,
    AdminPatientCursor? cursor,
  }) => _dataSource.getPatients(search: search, cursor: cursor);

  @override
  Future<AdminPatient?> getPatient(String uid) => _dataSource.getPatient(uid);

  @override
  Future<AdminPatientAppointmentsPage> getAppointments({
    required String patientUid,
    AdminPatientAppointmentCursor? cursor,
  }) => _dataSource.getAppointments(patientUid: patientUid, cursor: cursor);
}
