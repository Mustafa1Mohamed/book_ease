import 'dart:async';

import 'package:book_ease/features/admin/domain/entities/admin_patient.dart';
import 'package:book_ease/features/admin/domain/entities/admin_patient_appointments_page.dart';
import 'package:book_ease/features/admin/domain/entities/admin_patient_page.dart';
import 'package:book_ease/features/admin/domain/errors/admin_patient_exception.dart';
import 'package:book_ease/features/admin/domain/repositories/admin_patient_repository.dart';
import 'package:book_ease/features/admin/presentation/cubit/admin_patient_details_cubit.dart';
import 'package:book_ease/features/admin/presentation/cubit/admin_patient_list_cubit.dart';
import 'package:book_ease/features/my_appointments/domain/entities/my_appointment.dart';
import 'package:flutter_test/flutter_test.dart';

AdminPatient _patient(String uid) => AdminPatient(
  uid: uid,
  fullName: 'Patient $uid',
  email: '$uid@example.com',
  phoneNumber: '',
  profileImageUrl: '',
  role: 'patient',
);

MyAppointment _appointment(String id) => MyAppointment(
  id: id,
  patientId: 'patient-1',
  doctorId: 'doctor-1',
  doctorName: 'Doctor',
  doctorImageUrl: '',
  specialtyId: 'specialty-1',
  specialtyName: 'Family medicine',
  scheduledAt: DateTime(2030),
  status: 'confirmed',
);

class _PatientRepository implements AdminPatientRepository {
  final patientRequests = <({String search, AdminPatientCursor? cursor})>[];
  final appointmentRequests =
      <({String patientUid, AdminPatientAppointmentCursor? cursor})>[];
  final Map<String, AdminPatient> profiles = {
    'patient-1': _patient('patient-1'),
  };
  Future<AdminPatientPage> Function(String search, AdminPatientCursor? cursor)?
  patientPage;
  Future<AdminPatientAppointmentsPage> Function(
    String patientUid,
    AdminPatientAppointmentCursor? cursor,
  )?
  appointmentPage;

  @override
  Future<AdminPatientPage> getPatients({
    required String search,
    AdminPatientCursor? cursor,
  }) {
    patientRequests.add((search: search, cursor: cursor));
    return patientPage?.call(search, cursor) ??
        Future.value(const AdminPatientPage(patients: [], hasMore: false));
  }

  @override
  Future<AdminPatient?> getPatient(String uid) async => profiles[uid];

  @override
  Future<AdminPatientAppointmentsPage> getAppointments({
    required String patientUid,
    AdminPatientAppointmentCursor? cursor,
  }) {
    appointmentRequests.add((patientUid: patientUid, cursor: cursor));
    return appointmentPage?.call(patientUid, cursor) ??
        Future.value(
          const AdminPatientAppointmentsPage(appointments: [], hasMore: false),
        );
  }
}

void main() {
  group('AdminPatientListCubit', () {
    test(
      'loads 20 results and appends the next cursor page without duplicates',
      () async {
        final repository = _PatientRepository()
          ..patientPage = (_, cursor) async => cursor == null
              ? AdminPatientPage(
                  patients: List.generate(20, (index) => _patient('$index')),
                  hasMore: true,
                  nextCursor: const AdminPatientCursor(documentId: '19'),
                )
              : AdminPatientPage(
                  patients: [_patient('19'), _patient('20')],
                  hasMore: false,
                );
        final cubit = AdminPatientListCubit(repository);
        addTearDown(cubit.close);

        await cubit.load();
        expect(cubit.state.patients, hasLength(20));
        expect(cubit.state.hasMore, isTrue);

        await cubit.loadMore();
        expect(cubit.state.patients, hasLength(21));
        expect(
          cubit.state.patients.map((patient) => patient.uid).toSet(),
          hasLength(21),
        );
        expect(cubit.state.hasMore, isFalse);
        expect(repository.patientRequests.last.cursor?.documentId, '19');
        await cubit.loadMore();
        expect(repository.patientRequests, hasLength(2));
      },
    );

    test(
      'refresh resets the cursor and search starts a fresh paginated query',
      () async {
        final repository = _PatientRepository()
          ..patientPage = (search, cursor) async => AdminPatientPage(
            patients: [_patient('$search-${cursor?.documentId ?? 'first'}')],
            hasMore: cursor == null,
            nextCursor: cursor == null
                ? const AdminPatientCursor(documentId: 'first')
                : null,
          );
        final cubit = AdminPatientListCubit(repository);
        addTearDown(cubit.close);

        await cubit.load();
        await cubit.loadMore();
        await cubit.updateSearch('Sam');
        expect(repository.patientRequests.last.search, 'Sam');
        expect(repository.patientRequests.last.cursor, isNull);
        expect(cubit.state.patients.single.uid, 'Sam-first');
        expect(cubit.state.hasMore, isTrue);

        await cubit.load();
        expect(repository.patientRequests.last.search, 'Sam');
        expect(repository.patientRequests.last.cursor, isNull);
        expect(cubit.state.patients.single.uid, 'Sam-first');
      },
    );

    test('initial and pagination failures expose retryable states', () async {
      final repository = _PatientRepository();
      var failInitial = true;
      var failMore = true;
      repository.patientPage = (_, cursor) async {
        if (cursor == null && failInitial) {
          throw const AdminPatientException('unavailable');
        }
        if (cursor != null && failMore) {
          throw const AdminPatientException('unavailable');
        }
        return AdminPatientPage(
          patients: [_patient(cursor == null ? 'patient-1' : 'patient-2')],
          hasMore: cursor == null,
          nextCursor: cursor == null
              ? const AdminPatientCursor(documentId: 'patient-1')
              : null,
        );
      };
      final cubit = AdminPatientListCubit(repository);
      addTearDown(cubit.close);

      await cubit.load();
      expect(cubit.state.hasError, isTrue);
      failInitial = false;
      await cubit.load();
      expect(cubit.state.patients, hasLength(1));

      await cubit.loadMore();
      expect(cubit.state.loadMoreHasError, isTrue);
      failMore = false;
      await cubit.loadMore();
      expect(cubit.state.patients, hasLength(2));
      expect(cubit.state.loadMoreHasError, isFalse);
    });

    test('does not make concurrent pagination requests', () async {
      final pageGate = Completer<AdminPatientPage>();
      final repository = _PatientRepository()
        ..patientPage = (_, cursor) async => cursor == null
            ? AdminPatientPage(
                patients: [_patient('patient-1')],
                hasMore: true,
                nextCursor: const AdminPatientCursor(documentId: 'patient-1'),
              )
            : pageGate.future;
      final cubit = AdminPatientListCubit(repository);
      addTearDown(cubit.close);
      await cubit.load();

      final first = cubit.loadMore();
      await Future<void>.delayed(Duration.zero);
      await cubit.loadMore();
      expect(repository.patientRequests, hasLength(2));

      pageGate.complete(const AdminPatientPage(patients: [], hasMore: false));
      await first;
      expect(cubit.state.isLoadingMore, isFalse);
    });

    test('empty and no-result searches end pagination cleanly', () async {
      final repository = _PatientRepository();
      final cubit = AdminPatientListCubit(repository);
      addTearDown(cubit.close);

      await cubit.load();
      expect(cubit.state.patients, isEmpty);
      expect(cubit.state.hasMore, isFalse);
      await cubit.updateSearch('no match');
      expect(cubit.state.patients, isEmpty);
      expect(cubit.state.search, 'no match');
      expect(cubit.state.hasMore, isFalse);
    });
  });

  group('AdminPatientDetailsCubit', () {
    test('loads a profile and paginated appointment history', () async {
      final repository = _PatientRepository()
        ..appointmentPage = (_, cursor) async => cursor == null
            ? AdminPatientAppointmentsPage(
                appointments: [_appointment('appointment-1')],
                hasMore: true,
                nextCursor: AdminPatientAppointmentCursor(
                  documentId: 'appointment-1',
                  appointmentAt: DateTime(2030),
                ),
              )
            : AdminPatientAppointmentsPage(
                appointments: [
                  _appointment('appointment-1'),
                  _appointment('appointment-2'),
                ],
                hasMore: false,
              );
      final cubit = AdminPatientDetailsCubit(repository);
      addTearDown(cubit.close);

      await cubit.load('patient-1');
      expect(cubit.state.patient?.uid, 'patient-1');
      expect(cubit.state.appointments, hasLength(1));
      expect(cubit.state.appointmentsHasMore, isTrue);

      await cubit.loadMoreAppointments();
      expect(cubit.state.appointments, hasLength(2));
      expect(cubit.state.appointmentsHasMore, isFalse);
      expect(
        repository.appointmentRequests.last.cursor?.documentId,
        'appointment-1',
      );
    });

    test('handles missing profiles and appointment history retry', () async {
      final repository = _PatientRepository()..profiles.clear();
      final cubit = AdminPatientDetailsCubit(repository);
      addTearDown(cubit.close);
      await cubit.load('missing');

      expect(cubit.state.patient, isNull);
      expect(repository.appointmentRequests, isEmpty);

      repository.profiles['patient-1'] = _patient('patient-1');
      var failAppointments = true;
      repository.appointmentPage = (_, cursor) async {
        if (failAppointments) {
          throw const AdminPatientException('unavailable');
        }
        return const AdminPatientAppointmentsPage(
          appointments: [],
          hasMore: false,
        );
      };
      await cubit.load('patient-1');
      expect(cubit.state.patient?.uid, 'patient-1');
      expect(cubit.state.appointmentsHasError, isTrue);
      failAppointments = false;
      await cubit.retryAppointments();
      expect(cubit.state.appointmentsHasError, isFalse);
      expect(cubit.state.appointments, isEmpty);
    });
  });
}
