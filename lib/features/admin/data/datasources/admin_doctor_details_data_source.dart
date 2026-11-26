import '../../domain/entities/admin_doctor_details.dart';

abstract interface class AdminDoctorDetailsDataSource {
  Future<AdminDoctorDetails> getDoctorDetails(String doctorId);

  Future<AdminDoctorAuditPage> getAuditHistory({
    required String targetDoctorUid,
    AdminDoctorAuditCursor? cursor,
  });
}
