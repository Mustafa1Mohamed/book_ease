import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/doctor_profile_resolver.dart';
import '../../domain/entities/admin_doctor.dart';
import 'admin_doctor_model.dart';

class AdminDoctorSnapshotMapper {
  const AdminDoctorSnapshotMapper(this._firestore);

  final FirebaseFirestore _firestore;

  Future<AdminDoctor> map(
    DocumentSnapshot<Map<String, dynamic>> snapshot, {
    Map<String, dynamic>? knownUserData,
  }) async {
    final doctor = snapshot.data() ?? const <String, dynamic>{};
    final doctorUid = doctor['uid'];
    final uid = doctorUid is String && doctorUid.trim().isNotEmpty
        ? doctorUid.trim()
        : snapshot.id;
    final userData =
        knownUserData ??
        (await _firestore.collection('users').doc(uid).get()).data();
    final matches = await _firestore
        .collection('doctors')
        .where('uid', isEqualTo: uid)
        .limit(2)
        .get();
    final resolved = await DoctorProfileResolver(_firestore)
        .resolve(uid: uid, userData: userData);
    return AdminDoctorModel.fromSnapshots(
      id: snapshot.id,
      doctor: doctor,
      user: userData,
      identityVerified: resolved?.id == snapshot.id,
      identityAmbiguous: matches.docs.length > 1,
    );
  }
}
