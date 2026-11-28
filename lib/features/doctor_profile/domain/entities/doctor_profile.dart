import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/doctor_lifecycle_status.dart';

class DoctorProfile extends Equatable {
  const DoctorProfile({
    required this.uid,
    required this.doctorId,
    required this.fullName,
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
  });

  final String uid;
  final String doctorId;
  final String fullName;
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

  double get profileCompleteness {
    final available = <bool>[
      fullName.isNotEmpty,
      email.isNotEmpty,
      phoneNumber.isNotEmpty,
      profileImageUrl.isNotEmpty,
      specialtyName.isNotEmpty,
      consultationFee != null,
      biography.isNotEmpty,
      yearsExperience != null,
      clinicAddress.isNotEmpty,
    ];
    return available.where((value) => value).length / available.length;
  }

  @override
  List<Object?> get props => [
    uid,
    doctorId,
    fullName,
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
  ];
}
