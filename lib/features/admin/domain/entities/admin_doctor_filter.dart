import 'admin_doctor.dart';
import '../../../auth/domain/entities/user_role.dart';

enum AdminDoctorFilter {
  all,
  pending,
  approved,
  rejected,
  suspended;

  bool matchesLifecycle(AdminDoctor doctor) => switch (this) {
    AdminDoctorFilter.all => true,
    AdminDoctorFilter.pending =>
      doctor.lifecycle.approvalStatus == DoctorApprovalStatus.pending,
    AdminDoctorFilter.approved =>
      doctor.lifecycle.approvalStatus == DoctorApprovalStatus.approved,
    AdminDoctorFilter.rejected =>
      doctor.lifecycle.isValid &&
          doctor.lifecycle.approvalStatus == DoctorApprovalStatus.rejected,
    AdminDoctorFilter.suspended => doctor.lifecycle.isSuspended,
  };
}

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
