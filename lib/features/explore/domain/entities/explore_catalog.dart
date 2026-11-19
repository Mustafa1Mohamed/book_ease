import 'package:equatable/equatable.dart';

import '../../../home/domain/entities/featured_doctor.dart';
import '../../../home/domain/entities/home_section_data.dart';
import '../../../home/domain/entities/medical_specialty.dart';

class ExploreCatalog extends Equatable {
  const ExploreCatalog({required this.specialties, required this.doctors});

  final HomeSectionData<List<MedicalSpecialty>> specialties;
  final HomeSectionData<List<FeaturedDoctor>> doctors;

  @override
  List<Object?> get props => [specialties, doctors];
}
