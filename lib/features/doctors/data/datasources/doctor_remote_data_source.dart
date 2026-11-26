import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../auth/domain/entities/doctor_lifecycle_status.dart';
import '../../../home/data/models/featured_doctor_model.dart';
import '../../../home/domain/entities/featured_doctor.dart';

class DoctorRemoteDataSource {
  const DoctorRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Future<FeaturedDoctor?> getDoctor(String doctorId) async {
    final snapshot = await _firestore.collection('doctors').doc(doctorId).get();
    final data = snapshot.data();
    if (data == null ||
        !DoctorLifecycleStatus.fromDoctorData(data).canOperate) {
      return null;
    }

    final specialtyId = data['specialtyId'];
    var specialtyNamesById = const <String, String>{};
    if (specialtyId is String && specialtyId.isNotEmpty) {
      try {
        final specialty = await _firestore
            .collection('specialties')
            .doc(specialtyId)
            .get();
        final name = specialty.data()?['name'];
        if (name is String && name.trim().isNotEmpty) {
          specialtyNamesById = {specialtyId: name.trim()};
        }
      } on FirebaseException {
        // Specialty details are optional; preserve the doctor record.
      }
    }

    return FeaturedDoctorModel.fromMap(
      snapshot.id,
      data,
      specialtyNamesById: specialtyNamesById,
    );
  }
}
