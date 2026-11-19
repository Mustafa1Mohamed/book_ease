import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../home/domain/entities/featured_doctor.dart';
import '../../domain/errors/doctor_exception.dart';
import '../../domain/repositories/doctor_repository.dart';
import '../datasources/doctor_remote_data_source.dart';

class DoctorRepositoryImpl implements DoctorRepository {
  const DoctorRepositoryImpl(this._remoteDataSource);

  final DoctorRemoteDataSource _remoteDataSource;

  @override
  Future<FeaturedDoctor?> getDoctor(String doctorId) async {
    try {
      return await _remoteDataSource.getDoctor(doctorId);
    } on FirebaseException {
      throw const DoctorException(
        'Doctor details could not be loaded. Please try again.',
      );
    }
  }
}
