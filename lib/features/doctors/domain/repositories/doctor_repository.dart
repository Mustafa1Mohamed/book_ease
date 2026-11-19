import '../../../home/domain/entities/featured_doctor.dart';

abstract interface class DoctorRepository {
  Future<FeaturedDoctor?> getDoctor(String doctorId);
}
