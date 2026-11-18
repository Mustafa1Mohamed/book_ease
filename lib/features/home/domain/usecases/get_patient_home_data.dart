import '../entities/patient_home_data.dart';
import '../repositories/patient_home_repository.dart';

class GetPatientHomeData {
  const GetPatientHomeData(this._repository);

  final PatientHomeRepository _repository;

  Future<PatientHomeData> call() => _repository.loadHomeData();
}
