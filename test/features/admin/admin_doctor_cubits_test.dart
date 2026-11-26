import 'dart:async';

import 'package:book_ease/features/admin/domain/entities/admin_doctor.dart';
import 'package:book_ease/features/admin/domain/entities/admin_doctor_audit_event.dart';
import 'package:book_ease/features/admin/domain/entities/admin_doctor_action.dart';
import 'package:book_ease/features/admin/domain/entities/admin_doctor_details.dart';
import 'package:book_ease/features/admin/domain/entities/admin_doctor_filter.dart';
import 'package:book_ease/features/admin/domain/errors/admin_doctor_exception.dart';
import 'package:book_ease/features/admin/domain/repositories/admin_doctor_repository.dart';
import 'package:book_ease/features/admin/presentation/cubit/admin_doctor_details_cubit.dart';
import 'package:book_ease/features/admin/presentation/cubit/admin_doctor_list_cubit.dart';
import 'package:book_ease/features/auth/domain/entities/doctor_lifecycle_status.dart';
import 'package:book_ease/features/my_appointments/domain/entities/my_appointment.dart';
import 'package:flutter_test/flutter_test.dart';

final _doctor = AdminDoctor(
  id: 'profile-1',
  uid: 'doctor-1',
  name: 'Doctor',
  email: 'doctor@example.com',
  phoneNumber: '',
  profileImageUrl: '',
  specialtyId: 'specialty-1',
  specialtyName: 'Family medicine',
  consultationFee: 50,
  biography: '',
  qualifications: const [],
  yearsExperience: null,
  languages: const [],
  clinicName: '',
  clinicAddress: '',
  lifecycle: DoctorLifecycleStatus.fromDoctorData({
    'approvalStatus': 'pending',
    'administrativeStatus': 'active',
  }),
  warnings: const [],
  identityVerified: true,
);

class _FakeAdminDoctorRepository implements AdminDoctorRepository {
  final requests =
      <
        ({String search, AdminDoctorFilter filter, AdminDoctorCursor? cursor})
      >[];
  final operationIds = <String>[];
  final appointment = MyAppointment(
    id: 'appointment-1',
    patientId: 'patient-1',
    doctorId: 'profile-1',
    doctorName: 'Doctor',
    doctorImageUrl: '',
    specialtyId: 'specialty-1',
    specialtyName: 'Family medicine',
    scheduledAt: DateTime(2030),
    status: 'confirmed',
  );
  int actionAttempts = 0;
  bool failFirstAction = false;
  Completer<void>? actionGate;
  final auditEvent = AdminDoctorAuditEvent(
    id: 'audit-1',
    actorUid: 'admin-1',
    targetDoctorUid: 'doctor-1',
    doctorProfileId: 'profile-1',
    action: 'approve',
    previousApprovalStatus: 'pending',
    newApprovalStatus: 'approved',
    previousAdministrativeStatus: 'active',
    newAdministrativeStatus: 'active',
    reason: '',
    createdAt: DateTime(2030),
  );

  @override
  Future<AdminDoctorPage> getDoctors({
    required AdminDoctorFilter filter,
    required String search,
    required String specialtyId,
    AdminDoctorCursor? cursor,
  }) async {
    requests.add((search: search, filter: filter, cursor: cursor));
    if (cursor == null) {
      return AdminDoctorPage(
        doctors: [_doctor],
        hasMore: true,
        nextCursor: const AdminDoctorCursor(documentId: 'profile-1'),
      );
    }
    return const AdminDoctorPage(doctors: [], hasMore: false);
  }

  @override
  Future<List<AdminDoctorSpecialty>> getSpecialties() async => const [];

  @override
  Future<AdminDoctorDetails> getDoctorDetails(String doctorId) async =>
      AdminDoctorDetails(doctor: _doctor, upcomingAppointments: [appointment]);

  @override
  Future<AdminDoctorAuditPage> getAuditHistory({
    required String targetDoctorUid,
    AdminDoctorAuditCursor? cursor,
  }) async {
    if (cursor == null) {
      return AdminDoctorAuditPage(
        events: [auditEvent],
        hasMore: true,
        nextCursor: AdminDoctorAuditCursor(
          documentId: auditEvent.id,
          createdAt: auditEvent.createdAt!,
        ),
      );
    }
    return const AdminDoctorAuditPage(events: [], hasMore: false);
  }

  @override
  Future<void> performAction({
    required String actionName,
    required String targetDoctorUid,
    required String operationId,
    String? reason,
  }) async {
    actionAttempts++;
    operationIds.add(operationId);
    if (actionGate case final gate?) await gate.future;
    if (failFirstAction && actionAttempts == 1) {
      throw const AdminDoctorException('unavailable');
    }
  }
}

void main() {
  late _FakeAdminDoctorRepository repository;

  setUp(() => repository = _FakeAdminDoctorRepository());

  test('doctor list passes filters and appends cursor pages', () async {
    final cubit = AdminDoctorListCubit(repository);
    addTearDown(cubit.close);

    await cubit.load();
    expect(cubit.state.doctors.map((doctor) => doctor.id), ['profile-1']);
    expect(cubit.state.hasMore, isTrue);

    await cubit.loadMore();
    expect(cubit.state.doctors, hasLength(1));
    expect(cubit.state.hasMore, isFalse);
    expect(repository.requests.last.cursor?.documentId, 'profile-1');

    await cubit.updateFilter(AdminDoctorFilter.pending);
    await cubit.updateSearch('doctor@example.com');
    expect(repository.requests.last.filter, AdminDoctorFilter.pending);
    expect(repository.requests.last.search, 'doctor@example.com');
    expect(repository.requests.last.cursor, isNull);
  });

  test('retrying the same failed action reuses its operation id', () async {
    repository.failFirstAction = true;
    final cubit = AdminDoctorDetailsCubit(repository);
    addTearDown(cubit.close);
    await cubit.load('profile-1');

    await cubit.performAction(action: AdminDoctorAction.approve, reason: '');
    expect(cubit.state.actionFailed, isTrue);

    await cubit.performAction(action: AdminDoctorAction.approve, reason: '');
    expect(repository.operationIds, hasLength(2));
    expect(repository.operationIds.first, repository.operationIds.last);
    expect(repository.actionAttempts, 2);
  });

  test('in-flight action prevents duplicate submissions', () async {
    repository.actionGate = Completer<void>();
    final cubit = AdminDoctorDetailsCubit(repository);
    addTearDown(cubit.close);
    await cubit.load('profile-1');

    final first = cubit.performAction(
      action: AdminDoctorAction.approve,
      reason: '',
    );
    await Future<void>.delayed(Duration.zero);
    await cubit.performAction(action: AdminDoctorAction.approve, reason: '');
    expect(repository.actionAttempts, 1);

    repository.actionGate!.complete();
    await first;
  });

  test('details retain upcoming appointments for operational review', () async {
    final cubit = AdminDoctorDetailsCubit(repository);
    addTearDown(cubit.close);

    await cubit.load('profile-1');

    expect(cubit.state.details?.upcomingAppointments, [repository.appointment]);
  });

  test('audit history loads subsequent pages with its cursor', () async {
    final cubit = AdminDoctorDetailsCubit(repository);
    addTearDown(cubit.close);
    await cubit.load('profile-1');

    expect(cubit.state.auditEvents, [repository.auditEvent]);
    expect(cubit.state.auditHasMore, isTrue);

    await cubit.loadMoreAudit();

    expect(cubit.state.auditEvents, [repository.auditEvent]);
    expect(cubit.state.auditHasMore, isFalse);
  });
}
