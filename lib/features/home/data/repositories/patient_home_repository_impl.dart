import 'package:firebase_core/firebase_core.dart';

import '../../domain/entities/patient_home_data.dart';
import '../../domain/errors/patient_home_exception.dart';
import '../../domain/repositories/patient_home_repository.dart';
import '../datasources/patient_home_data_source.dart';

class PatientHomeRepositoryImpl implements PatientHomeRepository {
  const PatientHomeRepositoryImpl(this._dataSource);

  final PatientHomeDataSource _dataSource;

  @override
  Future<PatientHomeData> loadHomeData() async {
    try {
      return await _dataSource.loadHomeData();
    } on PatientHomeException {
      rethrow;
    } on FirebaseException {
      throw const PatientHomeException(
        'Home data could not be loaded. Please try again.',
      );
    }
  }
}
