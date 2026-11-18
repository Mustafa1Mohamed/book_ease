import 'package:equatable/equatable.dart';

class FeaturedDoctor extends Equatable {
  const FeaturedDoctor({
    required this.id,
    required this.fullName,
    required this.specialtyId,
    required this.specialtyName,
    required this.imageUrl,
    required this.rating,
    required this.consultationFee,
    required this.isAvailable,
  });

  final String id;
  final String fullName;
  final String specialtyId;
  final String specialtyName;
  final String imageUrl;
  final double? rating;
  final double? consultationFee;
  final bool? isAvailable;

  @override
  List<Object?> get props => [
    id,
    fullName,
    specialtyId,
    specialtyName,
    imageUrl,
    rating,
    consultationFee,
    isAvailable,
  ];
}
