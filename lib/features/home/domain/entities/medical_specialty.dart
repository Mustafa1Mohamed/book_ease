import 'package:equatable/equatable.dart';

class MedicalSpecialty extends Equatable {
  const MedicalSpecialty({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.iconName,
    this.nameAr = '',
  });

  final String id;
  final String name;
  final String imageUrl;
  final String iconName;
  final String nameAr;

  String localizedName(String languageCode) =>
      languageCode == 'ar' && nameAr.isNotEmpty ? nameAr : name;

  bool matches(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    return normalizedQuery.isEmpty ||
        name.toLowerCase().contains(normalizedQuery) ||
        nameAr.toLowerCase().contains(normalizedQuery);
  }

  @override
  List<Object?> get props => [id, name, nameAr, imageUrl, iconName];
}
