import 'package:equatable/equatable.dart';

import 'user_role.dart';

enum DoctorAdministrativeStatus {
  active,
  suspended,
  unknown;

  static DoctorAdministrativeStatus fromFirestore(Object? value) =>
      switch (value) {
        'active' => DoctorAdministrativeStatus.active,
        'suspended' => DoctorAdministrativeStatus.suspended,
        _ => DoctorAdministrativeStatus.unknown,
      };
}

class DoctorLifecycleStatus extends Equatable {
  const DoctorLifecycleStatus({
    required this.approvalStatus,
    required this.administrativeStatus,
    required this.isValid,
  });

  static const pending = DoctorLifecycleStatus(
    approvalStatus: DoctorApprovalStatus.pending,
    administrativeStatus: DoctorAdministrativeStatus.active,
    isValid: true,
  );

  static const profileMissing = DoctorLifecycleStatus(
    approvalStatus: DoctorApprovalStatus.profileMissing,
    administrativeStatus: DoctorAdministrativeStatus.unknown,
    isValid: false,
  );

  static const unknown = DoctorLifecycleStatus(
    approvalStatus: DoctorApprovalStatus.unknown,
    administrativeStatus: DoctorAdministrativeStatus.unknown,
    isValid: false,
  );

  factory DoctorLifecycleStatus.fromDoctorData(Map<String, dynamic>? data) {
    if (data == null) return profileMissing;

    final approvalStatus = data.containsKey('approvalStatus')
        ? DoctorApprovalStatus.fromFirestore(data['approvalStatus'])
        : DoctorApprovalStatus.pending;
    final administrativeStatus = data.containsKey('administrativeStatus')
        ? DoctorAdministrativeStatus.fromFirestore(data['administrativeStatus'])
        : DoctorAdministrativeStatus.active;
    final isValid =
        approvalStatus != DoctorApprovalStatus.unknown &&
        approvalStatus != DoctorApprovalStatus.profileMissing &&
        administrativeStatus != DoctorAdministrativeStatus.unknown &&
        (administrativeStatus != DoctorAdministrativeStatus.suspended ||
            approvalStatus == DoctorApprovalStatus.approved);

    return DoctorLifecycleStatus(
      approvalStatus: approvalStatus,
      administrativeStatus: administrativeStatus,
      isValid: isValid,
    );
  }

  final DoctorApprovalStatus approvalStatus;
  final DoctorAdministrativeStatus administrativeStatus;
  final bool isValid;

  bool get canOperate =>
      isValid &&
      approvalStatus == DoctorApprovalStatus.approved &&
      administrativeStatus == DoctorAdministrativeStatus.active;

  bool get isSuspended =>
      isValid &&
      approvalStatus == DoctorApprovalStatus.approved &&
      administrativeStatus == DoctorAdministrativeStatus.suspended;

  DoctorApprovalStatus get accountApprovalStatus =>
      isValid ? approvalStatus : DoctorApprovalStatus.unknown;

  @override
  List<Object?> get props => [approvalStatus, administrativeStatus, isValid];
}
