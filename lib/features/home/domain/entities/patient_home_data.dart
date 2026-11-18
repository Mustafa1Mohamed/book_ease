import 'package:equatable/equatable.dart';

import 'featured_doctor.dart';
import 'home_section_data.dart';
import 'medical_specialty.dart';
import 'patient_profile.dart';
import 'upcoming_appointment.dart';

class PatientHomeData extends Equatable {
  const PatientHomeData({
    required this.profile,
    required this.specialties,
    required this.featuredDoctors,
    required this.upcomingAppointment,
  });

  final PatientProfile profile;
  final HomeSectionData<List<MedicalSpecialty>> specialties;
  final HomeSectionData<List<FeaturedDoctor>> featuredDoctors;
  final HomeSectionData<UpcomingAppointment?> upcomingAppointment;

  @override
  List<Object?> get props => [
    profile,
    specialties,
    featuredDoctors,
    upcomingAppointment,
  ];
}
