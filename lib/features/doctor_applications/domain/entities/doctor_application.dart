import 'package:equatable/equatable.dart';

enum DoctorApplicationStatus {
  pending,
  approved,
  rejected,
  unknown;

  static DoctorApplicationStatus fromValue(Object? value) => switch (value) {
    'pending' => DoctorApplicationStatus.pending,
    'approved' => DoctorApplicationStatus.approved,
    'rejected' => DoctorApplicationStatus.rejected,
    _ => DoctorApplicationStatus.unknown,
  };
}

class DoctorApplication extends Equatable {
  const DoctorApplication({
    required this.id,
    required this.applicantUid,
    required this.applicantName,
    required this.applicantEmail,
    required this.applicantPhone,
    required this.profileImageUrl,
    required this.specialtyId,
    required this.specialtyName,
    required this.qualification,
    required this.experienceYears,
    required this.bio,
    required this.consultationFee,
    required this.clinicAddress,
    required this.status,
    required this.submittedAt,
    required this.reviewedAt,
    required this.reviewerUid,
    required this.rejectionReason,
    required this.doctorProfileId,
  });

  final String id;
  final String applicantUid;
  final String applicantName;
  final String applicantEmail;
  final String applicantPhone;
  final String profileImageUrl;
  final String specialtyId;
  final String specialtyName;
  final String qualification;
  final int experienceYears;
  final String bio;
  final double consultationFee;
  final String clinicAddress;
  final DoctorApplicationStatus status;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final String reviewerUid;
  final String rejectionReason;
  final String doctorProfileId;

  @override
  List<Object?> get props => [
    id,
    applicantUid,
    applicantName,
    applicantEmail,
    applicantPhone,
    profileImageUrl,
    specialtyId,
    specialtyName,
    qualification,
    experienceYears,
    bio,
    consultationFee,
    clinicAddress,
    status,
    submittedAt,
    reviewedAt,
    reviewerUid,
    rejectionReason,
    doctorProfileId,
  ];
}

class DoctorApplicantAccount extends Equatable {
  const DoctorApplicantAccount({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.profileImageUrl,
    required this.role,
  });

  final String fullName;
  final String email;
  final String phoneNumber;
  final String profileImageUrl;
  final String role;

  @override
  List<Object?> get props => [
    fullName,
    email,
    phoneNumber,
    profileImageUrl,
    role,
  ];
}
