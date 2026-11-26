import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorProfileResolver {
  const DoctorProfileResolver(this._firestore);

  final FirebaseFirestore _firestore;

  Future<DocumentSnapshot<Map<String, dynamic>>?> resolve({
    required String uid,
    required Map<String, dynamic>? userData,
  }) async {
    if (uid.isEmpty || userData?['role'] != 'doctor') return null;

    final doctors = _firestore.collection('doctors');
    final matches = await doctors.where('uid', isEqualTo: uid).limit(2).get();
    if (matches.docs.length > 1) return null;

    late final DocumentSnapshot<Map<String, dynamic>> legacy;
    try {
      legacy = await doctors.doc(uid).get();
    } on FirebaseException catch (error) {
      if (error.code == 'permission-denied') return null;
      rethrow;
    }
    if (userData!.containsKey('doctorProfileId')) {
      final linkedId = userData['doctorProfileId'];
      if (linkedId is! String ||
          linkedId.isEmpty ||
          linkedId.trim() != linkedId ||
          linkedId.contains('/')) {
        return null;
      }
      final linked = await doctors.doc(linkedId).get();
      if (!linked.exists ||
          linked.data()?['uid'] != uid ||
          matches.docs.length != 1 ||
          matches.docs.single.id != linkedId ||
          (legacy.exists && legacy.id != linkedId)) {
        return null;
      }
      return linked;
    }

    if (matches.docs.length == 1) {
      final match = matches.docs.single;
      if (legacy.exists && legacy.id != match.id) return null;
      return match;
    }

    final legacyUid = legacy.data()?['uid'];
    if (legacy.exists &&
        (legacyUid == null || legacyUid == '') &&
        legacy.id == uid) {
      return legacy;
    }
    return null;
  }

  static bool isLinkedProfile({
    required String uid,
    required String doctorId,
    required Map<String, dynamic> userData,
    required Map<String, dynamic> doctorData,
  }) {
    if (userData['role'] != 'doctor') return false;

    if (userData.containsKey('doctorProfileId')) {
      return userData['doctorProfileId'] == doctorId &&
          doctorData['uid'] == uid;
    }

    final doctorUid = doctorData['uid'];
    if (doctorUid is String && doctorUid.isNotEmpty) {
      return doctorUid == uid;
    }
    return doctorId == uid && (doctorUid == null || doctorUid == '');
  }
}
