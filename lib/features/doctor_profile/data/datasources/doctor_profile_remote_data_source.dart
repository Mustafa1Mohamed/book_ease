import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/firebase/doctor_profile_resolver.dart';
import '../../../auth/domain/entities/doctor_lifecycle_status.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../domain/entities/doctor_profile.dart';
import '../../domain/errors/doctor_profile_exception.dart';

class DoctorProfileRemoteDataSource {
  const DoctorProfileRemoteDataSource(this._firestore, this._firebaseAuth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  Future<DoctorProfile> getOwnProfile() async {
    final resolved = await _resolveOwnProfile();
    final user = resolved.userData;
    final doctor = resolved.doctorData;
    final doctorSnapshot = resolved.snapshot;

    return DoctorProfile(
      uid: resolved.uid,
      doctorId: doctorSnapshot.id,
      fullName: _first(
        _string(doctor['fullName']),
        _string(doctor['name']),
        _string(user['fullName']),
      ),
      email: _first(_string(user['email']), _string(doctor['email'])),
      phoneNumber: _first(
        _string(doctor['phoneNumber']),
        _string(user['phoneNumber']),
      ),
      profileImageUrl: _first(
        _string(doctor['profileImageUrl']),
        _string(user['profileImageUrl']),
      ),
      specialtyId: _string(doctor['specialtyId']),
      specialtyName: _string(doctor['specialtyName']),
      consultationFee: _number(doctor['consultationFee']),
      biography: _first(
        _string(doctor['biography']),
        _string(doctor['description']),
      ),
      qualifications: _stringList(doctor['qualifications']),
      yearsExperience: _integer(doctor['yearsExperience']),
      languages: _stringList(doctor['languages']),
      clinicName: _string(doctor['clinicName']),
      clinicAddress: _string(doctor['clinicAddress']),
      lifecycle: DoctorLifecycleStatus.fromDoctorData(doctor),
    );
  }

  Future<DoctorProfile> updateProfile({
    required String fullName,
    required String phoneNumber,
    required double? consultationFee,
    required String biography,
    required int? yearsExperience,
    required String clinicName,
    required String clinicAddress,
  }) async {
    final resolved = await _resolveOwnProfile();
    if (!resolved.lifecycle.isValid ||
        resolved.lifecycle.approvalStatus != DoctorApprovalStatus.approved) {
      throw const DoctorProfileException(
        'Your profile can only be edited while the doctor account is approved.',
      );
    }

    final batch = _firestore.batch();
    batch.update(_firestore.collection('users').doc(resolved.uid), {
      'fullName': fullName.trim(),
      'phoneNumber': phoneNumber.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    final doctorUpdate = <String, dynamic>{
      'fullName': fullName.trim(),
      'phoneNumber': phoneNumber.trim(),
      'biography': biography.trim(),
      'clinicName': clinicName.trim(),
      'clinicAddress': clinicAddress.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (consultationFee != null) {
      doctorUpdate['consultationFee'] = consultationFee;
    } else {
      doctorUpdate['consultationFee'] = FieldValue.delete();
    }
    if (yearsExperience != null) {
      doctorUpdate['yearsExperience'] = yearsExperience;
    } else {
      doctorUpdate['yearsExperience'] = FieldValue.delete();
    }
    batch.update(
      _firestore.collection('doctors').doc(resolved.snapshot.id),
      doctorUpdate,
    );
    await batch.commit();
    return getOwnProfile();
  }

  Future<_ResolvedDoctorProfile> _resolveOwnProfile() async {
    final authUser = _firebaseAuth.currentUser;
    if (authUser == null) {
      throw const DoctorProfileException('Sign in to view your profile.');
    }
    final uid = authUser.uid;
    final userSnapshot = await _firestore.collection('users').doc(uid).get();
    final userData = userSnapshot.data();
    if (!userSnapshot.exists ||
        userData == null ||
        userData['role'] != 'doctor') {
      throw const DoctorProfileException(
        'This profile is only available to doctor accounts.',
      );
    }
    final doctorSnapshot = await DoctorProfileResolver(_firestore)
        .resolve(uid: uid, userData: userData);
    if (doctorSnapshot == null) {
      throw const DoctorProfileException(
        'A unique doctor profile could not be resolved for this account.',
      );
    }
    final doctorData = doctorSnapshot.data();
    if (doctorData == null) {
      throw const DoctorProfileException('The doctor profile is missing.');
    }
    return _ResolvedDoctorProfile(
      uid: uid,
      snapshot: doctorSnapshot,
      userData: userData,
      doctorData: doctorData,
      lifecycle: DoctorLifecycleStatus.fromDoctorData(doctorData),
    );
  }

  static String _string(Object? value) => value is String ? value.trim() : '';
  static String _first(String first, [String second = '', String third = '']) =>
      first.isNotEmpty ? first : (second.isNotEmpty ? second : third);
  static double? _number(Object? value) {
    final number = switch (value) {
      num value => value.toDouble(),
      String value => double.tryParse(value),
      _ => null,
    };
    return number != null && number.isFinite && number >= 0 ? number : null;
  }

  static int? _integer(Object? value) {
    final number = switch (value) {
      int value => value,
      num value when value.isFinite && value == value.roundToDouble() =>
        value.toInt(),
      String value => int.tryParse(value),
      _ => null,
    };
    return number != null && number >= 0 ? number : null;
  }

  static List<String> _stringList(Object? value) {
    if (value is! Iterable) return const [];
    return List.unmodifiable(
      value
          .whereType<String>()
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty),
    );
  }
}

class _ResolvedDoctorProfile {
  const _ResolvedDoctorProfile({
    required this.uid,
    required this.snapshot,
    required this.userData,
    required this.doctorData,
    required this.lifecycle,
  });

  final String uid;
  final DocumentSnapshot<Map<String, dynamic>> snapshot;
  final Map<String, dynamic> userData;
  final Map<String, dynamic> doctorData;
  final DoctorLifecycleStatus lifecycle;
}
