import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/doctor_lifecycle_status.dart';

enum AdminDoctorWarning {
  missingUser,
  missingDoctorProfile,
  userRoleMismatch,
  identityMissing,
  identityLegacy,
  identityMismatch,
  identityAmbiguous,
  approvalStatusMissing,
  administrativeStatusMissing,
  invalidStatus,
  nameMissing,
  emailMissing,
  specialtyMissing,
  consultationFeeMissing,
}

class AdminDoctor extends Equatable {
  const AdminDoctor({
    required this.id,
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.profileImageUrl,
    required this.specialtyId,
    required this.specialtyName,
    required this.consultationFee,
    required this.biography,
    required this.qualifications,
    required this.yearsExperience,
    required this.languages,
    required this.clinicName,
    required this.clinicAddress,
    required this.lifecycle,
    required this.warnings,
    required this.identityVerified,
  });

  final String id;
  final String uid;
  final String name;
  final String email;
  final String phoneNumber;
  final String profileImageUrl;
  final String specialtyId;
  final String specialtyName;
  final double? consultationFee;
  final String biography;
  final List<String> qualifications;
  final int? yearsExperience;
  final List<String> languages;
  final String clinicName;
  final String clinicAddress;
  final DoctorLifecycleStatus lifecycle;
  final List<AdminDoctorWarning> warnings;
  final bool identityVerified;

  bool get needsReview => warnings.isNotEmpty || !lifecycle.isValid;

  bool get canAdminister =>
      identityVerified && lifecycle.isValid && uid.isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    uid,
    name,
    email,
    phoneNumber,
    profileImageUrl,
    specialtyId,
    specialtyName,
    consultationFee,
    biography,
    qualifications,
    yearsExperience,
    languages,
    clinicName,
    clinicAddress,
    lifecycle,
    warnings,
    identityVerified,
  ];
}
