import 'package:equatable/equatable.dart';

class AdminDoctorAuditEvent extends Equatable {
  const AdminDoctorAuditEvent({
    required this.id,
    required this.actorUid,
    required this.targetDoctorUid,
    required this.doctorProfileId,
    required this.action,
    required this.previousApprovalStatus,
    required this.newApprovalStatus,
    required this.previousAdministrativeStatus,
    required this.newAdministrativeStatus,
    required this.reason,
    required this.createdAt,
  });

  final String id;
  final String actorUid;
  final String targetDoctorUid;
  final String doctorProfileId;
  final String action;
  final String previousApprovalStatus;
  final String newApprovalStatus;
  final String previousAdministrativeStatus;
  final String newAdministrativeStatus;
  final String reason;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
    id,
    actorUid,
    targetDoctorUid,
    doctorProfileId,
    action,
    previousApprovalStatus,
    newApprovalStatus,
    previousAdministrativeStatus,
    newAdministrativeStatus,
    reason,
    createdAt,
  ];
}
