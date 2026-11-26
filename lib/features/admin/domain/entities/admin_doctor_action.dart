import 'admin_doctor.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../auth/domain/entities/doctor_lifecycle_status.dart';

enum AdminDoctorAction { approve, reject, suspend, restore }

abstract final class AdminDoctorActionPolicy {
  static List<AdminDoctorAction> actionsFor(AdminDoctor doctor) {
    if (!doctor.canAdminister) return const [];
    final status = doctor.lifecycle;
    if (status.approvalStatus == DoctorApprovalStatus.pending &&
        status.administrativeStatus == DoctorAdministrativeStatus.active) {
      return const [AdminDoctorAction.approve, AdminDoctorAction.reject];
    }
    if (status.approvalStatus == DoctorApprovalStatus.approved &&
        status.administrativeStatus == DoctorAdministrativeStatus.active) {
      return const [AdminDoctorAction.suspend];
    }
    if (status.approvalStatus == DoctorApprovalStatus.approved &&
        status.administrativeStatus == DoctorAdministrativeStatus.suspended) {
      return const [AdminDoctorAction.restore];
    }
    return const [];
  }

  static bool reasonRequired(AdminDoctorAction action) =>
      action == AdminDoctorAction.reject || action == AdminDoctorAction.suspend;
}
