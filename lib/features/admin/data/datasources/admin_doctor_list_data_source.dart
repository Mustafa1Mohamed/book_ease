import '../../domain/entities/admin_doctor_filter.dart';

abstract interface class AdminDoctorListDataSource {
  Future<AdminDoctorPage> getDoctors({
    required AdminDoctorFilter filter,
    required String search,
    required String specialtyId,
    AdminDoctorCursor? cursor,
  });

  Future<List<AdminDoctorSpecialty>> getSpecialties();
}
