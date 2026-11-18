import '../entities/patient_home_data.dart';

abstract interface class PatientHomeRepository {
  Future<PatientHomeData> loadHomeData();
}
