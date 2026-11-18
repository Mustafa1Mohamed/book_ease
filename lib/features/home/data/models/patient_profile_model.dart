import '../../domain/entities/patient_profile.dart';

abstract final class PatientProfileModel {
  static PatientProfile fromMap(
    Map<String, dynamic> data, {
    required String fallbackName,
  }) {
    return PatientProfile(
      fullName: _string(data['fullName']).trim().isNotEmpty
          ? _string(data['fullName']).trim()
          : fallbackName.trim(),
      imageUrl: _string(data['profileImageUrl']),
      role: _string(data['role']).trim().toLowerCase(),
    );
  }

  static String _string(Object? value) => value is String ? value : '';
}
