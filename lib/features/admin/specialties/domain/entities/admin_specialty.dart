import 'package:equatable/equatable.dart';

class AdminSpecialty extends Equatable {
  const AdminSpecialty({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.description,
    required this.descriptionAr,
    required this.imageUrl,
    required this.iconName,
    required this.availability,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String nameAr;
  final String description;
  final String descriptionAr;
  final String imageUrl;
  final String iconName;
  final SpecialtyStatus availability;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isActive =>
      availability == SpecialtyStatus.active ||
      availability == SpecialtyStatus.legacyActive;

  @override
  List<Object?> get props => [
    id,
    name,
    nameAr,
    description,
    descriptionAr,
    imageUrl,
    iconName,
    availability,
    createdAt,
    updatedAt,
  ];
}

enum SpecialtyStatus { active, inactive, legacyActive, invalid }
