import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../auth/domain/entities/doctor_lifecycle_status.dart';
import '../../domain/entities/admin_doctor.dart';

abstract final class AdminDoctorModel {
  static AdminDoctor missingProfile({
    required String uid,
    required Map<String, dynamic> user,
    required bool identityAmbiguous,
  }) {
    final warnings = <AdminDoctorWarning>{
      AdminDoctorWarning.missingDoctorProfile,
      AdminDoctorWarning.invalidStatus,
      AdminDoctorWarning.specialtyMissing,
      AdminDoctorWarning.consultationFeeMissing,
    };
    if (_string(user['fullName']).isEmpty && _string(user['name']).isEmpty) {
      warnings.add(AdminDoctorWarning.nameMissing);
    }
    if (_string(user['email']).isEmpty) {
      warnings.add(AdminDoctorWarning.emailMissing);
    }
    warnings.add(
      identityAmbiguous
          ? AdminDoctorWarning.identityAmbiguous
          : AdminDoctorWarning.identityMissing,
    );
    return AdminDoctor(
      id: uid,
      uid: uid,
      name: _first(_string(user['fullName']), _string(user['name'])),
      email: _string(user['email']),
      phoneNumber: _string(user['phoneNumber']),
      profileImageUrl: _string(user['profileImageUrl']),
      specialtyId: '',
      specialtyName: '',
      consultationFee: null,
      biography: '',
      qualifications: const [],
      yearsExperience: null,
      languages: const [],
      clinicName: '',
      clinicAddress: '',
      lifecycle: DoctorLifecycleStatus.profileMissing,
      warnings: List.unmodifiable(warnings),
      identityVerified: false,
    );
  }

  static AdminDoctor fromSnapshots({
    required String id,
    required Map<String, dynamic> doctor,
    required Map<String, dynamic>? user,
    required bool identityVerified,
    required bool identityAmbiguous,
  }) {
    final lifecycle = DoctorLifecycleStatus.fromDoctorData(doctor);
    final uid = _string(doctor['uid']).trim().isNotEmpty
        ? _string(doctor['uid']).trim()
        : id;
    final warnings = <AdminDoctorWarning>{};
    if (user == null) {
      warnings.add(AdminDoctorWarning.missingUser);
    } else if (user['role'] != 'doctor') {
      warnings.add(AdminDoctorWarning.userRoleMismatch);
    }

    if (identityAmbiguous) {
      warnings.add(AdminDoctorWarning.identityAmbiguous);
    } else if (!identityVerified) {
      warnings.add(AdminDoctorWarning.identityMismatch);
    } else if (user != null && !user.containsKey('doctorProfileId')) {
      warnings.add(AdminDoctorWarning.identityLegacy);
    }

    if (!doctor.containsKey('approvalStatus')) {
      warnings.add(AdminDoctorWarning.approvalStatusMissing);
    }
    if (!doctor.containsKey('administrativeStatus')) {
      warnings.add(AdminDoctorWarning.administrativeStatusMissing);
    }
    if (!lifecycle.isValid) warnings.add(AdminDoctorWarning.invalidStatus);

    final name = _first(
      _string(doctor['fullName']),
      _string(doctor['name']),
      _string(user?['fullName']),
    );
    final email = _first(_string(user?['email']), _string(doctor['email']));
    final specialtyId = _string(doctor['specialtyId']);
    final specialtyName = _string(doctor['specialtyName']);
    final fee = _number(doctor['consultationFee']);
    if (name.isEmpty) warnings.add(AdminDoctorWarning.nameMissing);
    if (email.isEmpty) warnings.add(AdminDoctorWarning.emailMissing);
    if (specialtyId.isEmpty && specialtyName.isEmpty) {
      warnings.add(AdminDoctorWarning.specialtyMissing);
    }
    if (fee == null) warnings.add(AdminDoctorWarning.consultationFeeMissing);

    return AdminDoctor(
      id: id,
      uid: uid,
      name: name,
      email: email,
      phoneNumber: _first(
        _string(user?['phoneNumber']),
        _string(doctor['phoneNumber']),
      ),
      profileImageUrl: _first(
        _string(doctor['profileImageUrl']),
        _string(user?['profileImageUrl']),
      ),
      specialtyId: specialtyId,
      specialtyName: specialtyName,
      consultationFee: fee,
      biography: _first(
        _string(doctor['biography']),
        _string(doctor['description']),
      ),
      qualifications: _stringList(doctor['qualifications']),
      yearsExperience: _integer(doctor['yearsExperience']),
      languages: _stringList(doctor['languages']),
      clinicName: _string(doctor['clinicName']),
      clinicAddress: _string(doctor['clinicAddress']),
      lifecycle: lifecycle,
      warnings: List.unmodifiable(warnings),
      identityVerified: identityVerified && user?['role'] == 'doctor',
    );
  }

  static String _string(Object? value) => value is String ? value.trim() : '';

  static String _first(String first, [String second = '', String third = '']) {
    if (first.isNotEmpty) return first;
    if (second.isNotEmpty) return second;
    return third;
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

  static double? _number(Object? value) {
    final number = switch (value) {
      num value => value.toDouble(),
      String value => double.tryParse(value),
      _ => null,
    };
    return number != null && number.isFinite && number >= 0 ? number : null;
  }

  static DateTime? timestamp(Object? value) => switch (value) {
    Timestamp value => value.toDate(),
    DateTime value => value,
    _ => null,
  };
}
