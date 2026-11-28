import 'package:equatable/equatable.dart';

class FeaturedDoctor extends Equatable {
  const FeaturedDoctor({
    required this.id,
    required this.fullName,
    required this.specialtyId,
    required this.specialtyName,
    this.specialtyNameAr = '',
    required this.imageUrl,
    required this.rating,
    required this.consultationFee,
    required this.isAvailable,
    this.reviewCount,
    this.biography = '',
    this.qualifications = const [],
    this.yearsExperience,
    this.languages = const [],
    this.clinicName = '',
    this.clinicAddress = '',
    this.consultationDurationMinutes,
  });

  final String id;
  final String fullName;
  final String specialtyId;
  final String specialtyName;
  final String specialtyNameAr;
  final String imageUrl;
  final double? rating;
  final double? consultationFee;
  final bool? isAvailable;
  final int? reviewCount;
  final String biography;
  final List<String> qualifications;
  final int? yearsExperience;
  final List<String> languages;
  final String clinicName;
  final String clinicAddress;
  final int? consultationDurationMinutes;

  @override
  List<Object?> get props => [
    id,
    fullName,
    specialtyId,
    specialtyName,
    specialtyNameAr,
    imageUrl,
    rating,
    consultationFee,
    isAvailable,
    reviewCount,
    biography,
    qualifications,
    yearsExperience,
    languages,
    clinicName,
    clinicAddress,
    consultationDurationMinutes,
  ];
}
