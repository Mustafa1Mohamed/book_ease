import 'package:equatable/equatable.dart';

class MedicalSpecialty extends Equatable {
  const MedicalSpecialty({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.iconName,
  });

  final String id;
  final String name;
  final String imageUrl;
  final String iconName;

  @override
  List<Object?> get props => [id, name, imageUrl, iconName];
}
