enum UserRole {
  patient,
  doctor,
  admin,
  unknown;

  static UserRole fromFirestore(Object? value) {
    if (value == null) return UserRole.patient;
    if (value is! String) return UserRole.unknown;
    if (value.trim().isEmpty) return UserRole.patient;
    return switch (value.trim().toLowerCase()) {
      'patient' => UserRole.patient,
      'doctor' => UserRole.doctor,
      'admin' => UserRole.admin,
      _ => UserRole.unknown,
    };
  }

  String get firestoreValue => switch (this) {
    UserRole.patient => 'patient',
    UserRole.doctor => 'doctor',
    UserRole.admin => 'admin',
    UserRole.unknown => '',
  };
}

enum DoctorApprovalStatus {
  pending,
  approved,
  rejected,
  profileMissing,
  unknown;

  static DoctorApprovalStatus fromFirestore(Object? value) {
    if (value == null) return DoctorApprovalStatus.pending;
    if (value is! String) return DoctorApprovalStatus.unknown;
    if (value.trim().isEmpty) return DoctorApprovalStatus.pending;
    return switch (value.trim().toLowerCase()) {
      'pending' => DoctorApprovalStatus.pending,
      'approved' => DoctorApprovalStatus.approved,
      'rejected' => DoctorApprovalStatus.rejected,
      _ => DoctorApprovalStatus.unknown,
    };
  }
}
