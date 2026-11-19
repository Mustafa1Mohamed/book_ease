import '../../../home/domain/entities/featured_doctor.dart';
import '../repositories/doctor_repository.dart';

class GetDoctorDetails {
  const GetDoctorDetails(this._repository);

  final DoctorRepository _repository;

  Future<FeaturedDoctor?> call(String doctorId) {
    return _repository.getDoctor(doctorId);
  }
}
