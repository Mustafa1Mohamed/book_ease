import 'doctor_application.dart';

class DoctorApplicationPage {
  const DoctorApplicationPage({
    required this.applications,
    required this.hasMore,
    this.nextCursor,
  });

  final List<DoctorApplication> applications;
  final bool hasMore;
  final String? nextCursor;
}

class DoctorApplicationSpecialty {
  const DoctorApplicationSpecialty({
    required this.id,
    required this.name,
    this.nameAr = '',
  });

  final String id;
  final String name;
  final String nameAr;

  String localizedName(String languageCode) =>
      languageCode == 'ar' && nameAr.isNotEmpty ? nameAr : name;
}
