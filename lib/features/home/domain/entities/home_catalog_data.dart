import 'package:equatable/equatable.dart';

import 'featured_doctor.dart';
import 'home_section_data.dart';
import 'medical_specialty.dart';

class HomeCatalogData extends Equatable {
  const HomeCatalogData({
    required this.specialties,
    required this.featuredDoctors,
  });

  final HomeSectionData<List<MedicalSpecialty>> specialties;
  final HomeSectionData<List<FeaturedDoctor>> featuredDoctors;

  @override
  List<Object?> get props => [specialties, featuredDoctors];
}
