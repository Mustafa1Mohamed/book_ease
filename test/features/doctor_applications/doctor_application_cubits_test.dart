import 'dart:async';

import 'package:book_ease/features/doctor_applications/domain/entities/doctor_application.dart';
import 'package:book_ease/features/doctor_applications/domain/entities/doctor_application_page.dart';
import 'package:book_ease/features/doctor_applications/domain/errors/doctor_application_exception.dart';
import 'package:book_ease/features/doctor_applications/domain/repositories/doctor_application_repository.dart';
import 'package:book_ease/features/doctor_applications/presentation/cubit/admin_doctor_applications_cubit.dart';
import 'package:book_ease/features/doctor_applications/presentation/cubit/doctor_application_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

DoctorApplication _application(String id, DoctorApplicationStatus status) =>
    DoctorApplication(
      id: id,
      applicantUid: 'patient-1',
      applicantName: 'Patient One',
      applicantEmail: 'patient@example.com',
      applicantPhone: '+1 555 0100',
      profileImageUrl: '',
      specialtyId: 'cardiology',
      specialtyName: 'Cardiology',
      qualification: 'MD',
      experienceYears: 8,
      bio: 'A professional biography.',
      consultationFee: 80,
      clinicAddress: 'Main Street clinic',
      status: status,
      submittedAt: DateTime(2026),
      reviewedAt: null,
      reviewerUid: '',
      rejectionReason: '',
      doctorProfileId: '',
    );

class _FakeDoctorApplicationRepository implements DoctorApplicationRepository {
  DoctorApplication? current;
  bool failLoad = false;
  bool failSubmit = false;
  Completer<void>? submitGate;
  int submitCalls = 0;
  StreamController<List<DoctorApplicationSpecialty>>? specialtyUpdates;
  final requests =
      <({String status, String specialty, String search, String? cursor})>[];

  @override
  Future<DoctorApplication?> getLatestForCurrentUser() async {
    if (failLoad) {
      throw const DoctorApplicationException('Could not load application.');
    }
    return current;
  }

  @override
  Future<List<DoctorApplication>> getApplicantHistory(
    String applicantUid,
  ) async => current == null ? [] : [current!];

  @override
  Future<DoctorApplicantAccount?> getApplicantAccount(
    String applicantUid,
  ) async => const DoctorApplicantAccount(
    fullName: 'Patient One',
    email: 'patient@example.com',
    phoneNumber: '+1 555 0100',
    profileImageUrl: '',
    role: 'patient',
  );

  @override
  Future<List<DoctorApplicationSpecialty>> getSpecialties() async => const [
    DoctorApplicationSpecialty(id: 'cardiology', name: 'Cardiology'),
  ];

  @override
  Stream<List<DoctorApplicationSpecialty>> watchSpecialties() =>
      specialtyUpdates?.stream ??
      Stream.value(const [
        DoctorApplicationSpecialty(id: 'cardiology', name: 'Cardiology'),
      ]);

  @override
  Future<void> submit({
    required String fullName,
    required String phoneNumber,
    required String specialtyId,
    required String qualification,
    required int experienceYears,
    required String bio,
    required double consultationFee,
    required String clinicAddress,
  }) async {
    submitCalls++;
    await submitGate?.future;
    if (failSubmit) {
      throw const DoctorApplicationException('Submission failed.');
    }
  }

  @override
  Future<DoctorApplicationPage> getApplications({
    required String status,
    required String specialtyId,
    required String search,
    String? cursor,
  }) async {
    requests.add((
      status: status,
      specialty: specialtyId,
      search: search,
      cursor: cursor,
    ));
    if (cursor == null) {
      return DoctorApplicationPage(
        applications: [
          _application('application-1', DoctorApplicationStatus.pending),
        ],
        hasMore: true,
        nextCursor: 'application-1',
      );
    }
    return DoctorApplicationPage(
      applications: [
        _application('application-1', DoctorApplicationStatus.pending),
        _application('application-2', DoctorApplicationStatus.rejected),
      ],
      hasMore: false,
    );
  }

  @override
  Future<DoctorApplication?> getApplication(String applicationId) async =>
      current ?? _application(applicationId, DoctorApplicationStatus.pending);

  @override
  Future<void> review({
    required String applicationId,
    required bool approve,
    String? reason,
  }) async {
    current = _application(
      applicationId,
      approve
          ? DoctorApplicationStatus.approved
          : DoctorApplicationStatus.rejected,
    );
  }
}

void main() {
  test('loads current application status and form specialties', () async {
    final repository = _FakeDoctorApplicationRepository()
      ..current = _application(
        'application-1',
        DoctorApplicationStatus.pending,
      );
    final cubit = DoctorApplicationCubit(repository);

    await cubit.loadStatus();
    expect((cubit.state.application!).status, DoctorApplicationStatus.pending);

    await cubit.loadForm();
    expect(cubit.state.isForm, isTrue);
    expect(cubit.state.specialties.single.name, 'Cardiology');
    await cubit.close();
  });

  test(
    'keeps the doctor specialty dropdown synchronized with the catalog',
    () async {
      final repository = _FakeDoctorApplicationRepository()
        ..specialtyUpdates =
            StreamController<List<DoctorApplicationSpecialty>>.broadcast();
      final cubit = DoctorApplicationCubit(repository);

      final loading = cubit.loadForm();
      await Future<void>.delayed(Duration.zero);
      repository.specialtyUpdates!.add(const [
        DoctorApplicationSpecialty(id: 'cardiology', name: 'Cardiology'),
      ]);
      await loading;
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.specialties.single.name, 'Cardiology');

      repository.specialtyUpdates!.add(const [
        DoctorApplicationSpecialty(id: 'neurology', name: 'Neurology'),
      ]);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.specialties.single.name, 'Neurology');

      await cubit.close();
      await repository.specialtyUpdates!.close();
    },
  );

  test('reports status retrieval errors', () async {
    final repository = _FakeDoctorApplicationRepository()..failLoad = true;
    final cubit = DoctorApplicationCubit(repository);

    await cubit.loadStatus();

    expect(cubit.state.errorMessage, 'Could not load application.');
  });

  test('prevents concurrent application submissions', () async {
    final gate = Completer<void>();
    final repository = _FakeDoctorApplicationRepository()..submitGate = gate;
    final cubit = DoctorApplicationCubit(repository);
    await cubit.loadForm();

    final first = cubit.submit(
      fullName: 'Patient One',
      phoneNumber: '+1 555 0100',
      specialtyId: 'cardiology',
      qualification: 'MD',
      experienceYears: 8,
      bio: 'A professional biography.',
      consultationFee: 80,
      clinicAddress: 'Main Street clinic',
    );
    await cubit.submit(
      fullName: 'Patient One',
      phoneNumber: '+1 555 0100',
      specialtyId: 'cardiology',
      qualification: 'MD',
      experienceYears: 8,
      bio: 'A professional biography.',
      consultationFee: 80,
      clinicAddress: 'Main Street clinic',
    );
    gate.complete();
    await first;

    expect(repository.submitCalls, 1);
    expect(cubit.state.isSubmitted, isTrue);
  });

  test('admin list filters, paginates, and prevents duplicate rows', () async {
    final repository = _FakeDoctorApplicationRepository();
    final cubit = AdminDoctorApplicationsCubit(repository);
    await cubit.load();
    expect(repository.requests.first.status, 'pending');
    expect(cubit.state.applications, hasLength(1));

    await cubit.loadMore();
    expect(cubit.state.applications.map((app) => app.id).toList(), [
      'application-1',
      'application-2',
    ]);
    expect(cubit.state.hasMore, isFalse);

    await cubit.updateStatus('rejected');
    await cubit.updateSpecialty('cardiology');
    await cubit.updateSearch('patient');
    expect(repository.requests.last.status, 'rejected');
    expect(repository.requests.last.specialty, 'cardiology');
    expect(repository.requests.last.search, 'patient');
    expect(repository.requests.last.cursor, isNull);
  });

  test('refresh after opening details preserves selected filters', () async {
    final repository = _FakeDoctorApplicationRepository();
    final cubit = AdminDoctorApplicationsCubit(repository);
    await cubit.load();
    await cubit.updateStatus('approved');
    await cubit.updateSpecialty('cardiology');
    await cubit.updateSearch('patient');

    await cubit.reloadAfterReview();

    expect(repository.requests.last.status, 'approved');
    expect(repository.requests.last.specialty, 'cardiology');
    expect(repository.requests.last.search, 'patient');
    expect(repository.requests.last.cursor, isNull);
    await cubit.close();
  });

  test('application review refreshes its status', () async {
    final repository = _FakeDoctorApplicationRepository();
    final cubit = AdminDoctorApplicationDetailsCubit(repository);
    await cubit.load('application-1');
    await cubit.review(approve: true);

    expect(cubit.state.application?.status, DoctorApplicationStatus.approved);
  });
}
