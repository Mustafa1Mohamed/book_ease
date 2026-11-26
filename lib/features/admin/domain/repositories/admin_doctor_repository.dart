import '../entities/admin_doctor_details.dart';
import '../entities/admin_doctor_filter.dart';

abstract interface class AdminDoctorRepository {
  Future<AdminDoctorPage> getDoctors({
    required AdminDoctorFilter filter,
    required String search,
    required String specialtyId,
    AdminDoctorCursor? cursor,
  });

  Future<List<AdminDoctorSpecialty>> getSpecialties();

  Future<AdminDoctorDetails> getDoctorDetails(String doctorId);

  Future<AdminDoctorAuditPage> getAuditHistory({
    required String targetDoctorUid,
    AdminDoctorAuditCursor? cursor,
  });

  Future<void> performAction({
    required String actionName,
    required String targetDoctorUid,
    required String operationId,
    String? reason,
  });
}
