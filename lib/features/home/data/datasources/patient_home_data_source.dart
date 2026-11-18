import '../../domain/entities/patient_home_data.dart';

abstract interface class PatientHomeDataSource {
  Future<PatientHomeData> loadHomeData();
}
