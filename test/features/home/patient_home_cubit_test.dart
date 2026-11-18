import 'package:book_ease/features/home/domain/entities/patient_home_data.dart';
import 'package:book_ease/features/home/domain/entities/patient_profile.dart';
import 'package:book_ease/features/home/domain/entities/home_section_data.dart';
import 'package:book_ease/features/home/domain/errors/patient_home_exception.dart';
import 'package:book_ease/features/home/domain/repositories/patient_home_repository.dart';
import 'package:book_ease/features/home/domain/usecases/get_patient_home_data.dart';
import 'package:book_ease/features/home/presentation/cubit/patient_home_cubit.dart';
import 'package:book_ease/features/home/presentation/cubit/patient_home_state.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePatientHomeRepository implements PatientHomeRepository {
  PatientHomeData? data = const PatientHomeData(
    profile: PatientProfile(fullName: '', imageUrl: '', role: 'patient'),
    specialties: HomeSectionData(value: []),
    featuredDoctors: HomeSectionData(value: []),
    upcomingAppointment: HomeSectionData(value: null),
  );
  Exception? error;

  @override
  Future<PatientHomeData> loadHomeData() async {
    if (error case final value?) throw value;
    if (data case final value?) return value;
    throw StateError('Fake home data was not configured.');
  }
}

void main() {
  group('PatientHomeCubit', () {
    late _FakePatientHomeRepository repository;
    late PatientHomeCubit cubit;

    setUp(() {
      repository = _FakePatientHomeRepository();
      cubit = PatientHomeCubit(GetPatientHomeData(repository));
    });

    tearDown(() async => cubit.close());

    test('emits loading then loaded with empty Firestore data', () async {
      final expectedData = repository.data;
      if (expectedData == null) fail('Expected fake home data.');
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          const PatientHomeLoading(),
          PatientHomeLoaded(expectedData),
        ]),
      );

      await cubit.load();
      await expectation;
    });

    test('keeps section failures inside the loaded home data', () async {
      repository.data = const PatientHomeData(
        profile: PatientProfile(
          fullName: 'Patient',
          imageUrl: '',
          role: 'patient',
        ),
        specialties: HomeSectionData(value: [], hasError: true),
        featuredDoctors: HomeSectionData(value: []),
        upcomingAppointment: HomeSectionData(value: null),
      );

      await cubit.load();

      expect(cubit.state, isA<PatientHomeLoaded>());
      final state = cubit.state;
      if (state is! PatientHomeLoaded) fail('Expected loaded home data.');
      expect(state.data.specialties.hasError, isTrue);
      expect(state.data.featuredDoctors.hasError, isFalse);
    });

    test('keeps existing data and exposes refresh failures', () async {
      await cubit.load();
      repository.error = const PatientHomeException('Refresh failed.');

      final expectedData = repository.data;
      if (expectedData == null) fail('Expected fake home data.');
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          PatientHomeLoaded(expectedData, isRefreshing: true),
          PatientHomeLoaded(expectedData, refreshError: 'Refresh failed.'),
        ]),
      );

      await cubit.load();
      await expectation;
    });

    test('emits a failure when initial loading fails', () async {
      repository.error = const PatientHomeException('Unable to load.');
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          const PatientHomeLoading(),
          const PatientHomeFailure('Unable to load.'),
        ]),
      );

      await cubit.load();
      await expectation;
    });
  });
}
