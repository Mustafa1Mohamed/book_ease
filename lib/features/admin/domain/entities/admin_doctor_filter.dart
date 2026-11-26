import 'admin_doctor.dart';

enum AdminDoctorFilter { all, pending, approved, rejected, suspended }

class AdminDoctorSpecialty {
  const AdminDoctorSpecialty({required this.id, required this.name});

  final String id;
  final String name;
}

class AdminDoctorCursor {
  const AdminDoctorCursor({
    required this.documentId,
    this.sortValue,
    this.sortField,
  });

  final String documentId;
  final String? sortValue;
  final String? sortField;
}

class AdminDoctorPage {
  const AdminDoctorPage({
    required this.doctors,
    required this.hasMore,
    this.nextCursor,
  });

  final List<AdminDoctor> doctors;
  final bool hasMore;
  final AdminDoctorCursor? nextCursor;
}
