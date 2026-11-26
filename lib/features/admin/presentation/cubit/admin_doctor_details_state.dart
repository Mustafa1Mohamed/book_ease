import 'package:equatable/equatable.dart';

import '../../domain/entities/admin_doctor_audit_event.dart';
import '../../domain/entities/admin_doctor_details.dart';

class AdminDoctorDetailsState extends Equatable {
  const AdminDoctorDetailsState({
    this.details,
    this.auditEvents = const [],
    this.auditCursor,
    this.auditHasMore = false,
    this.isLoading = false,
    this.isAuditLoading = false,
    this.isActionLoading = false,
    this.hasError = false,
    this.auditHasError = false,
    this.actionSucceeded = false,
    this.actionFailed = false,
  });

  final AdminDoctorDetails? details;
  final List<AdminDoctorAuditEvent> auditEvents;
  final AdminDoctorAuditCursor? auditCursor;
  final bool auditHasMore;
  final bool isLoading;
  final bool isAuditLoading;
  final bool isActionLoading;
  final bool hasError;
  final bool auditHasError;
  final bool actionSucceeded;
  final bool actionFailed;

  AdminDoctorDetailsState copyWith({
    AdminDoctorDetails? details,
    List<AdminDoctorAuditEvent>? auditEvents,
    AdminDoctorAuditCursor? auditCursor,
    bool clearAuditCursor = false,
    bool? auditHasMore,
    bool? isLoading,
    bool? isAuditLoading,
    bool? isActionLoading,
    bool? hasError,
    bool? auditHasError,
    bool? actionSucceeded,
    bool? actionFailed,
  }) => AdminDoctorDetailsState(
    details: details ?? this.details,
    auditEvents: auditEvents ?? this.auditEvents,
    auditCursor: clearAuditCursor ? null : auditCursor ?? this.auditCursor,
    auditHasMore: auditHasMore ?? this.auditHasMore,
    isLoading: isLoading ?? this.isLoading,
    isAuditLoading: isAuditLoading ?? this.isAuditLoading,
    isActionLoading: isActionLoading ?? this.isActionLoading,
    hasError: hasError ?? this.hasError,
    auditHasError: auditHasError ?? this.auditHasError,
    actionSucceeded: actionSucceeded ?? this.actionSucceeded,
    actionFailed: actionFailed ?? this.actionFailed,
  );

  @override
  List<Object?> get props => [
    details,
    auditEvents,
    auditCursor,
    auditHasMore,
    isLoading,
    isAuditLoading,
    isActionLoading,
    hasError,
    auditHasError,
    actionSucceeded,
    actionFailed,
  ];
}
