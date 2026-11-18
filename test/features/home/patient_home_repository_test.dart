import 'package:book_ease/features/home/data/datasources/patient_home_data_source.dart';
import 'package:book_ease/features/home/data/repositories/patient_home_repository_impl.dart';
import 'package:book_ease/features/home/domain/entities/home_section_data.dart';
import 'package:book_ease/features/home/domain/entities/patient_home_data.dart';
import 'package:book_ease/features/home/domain/entities/patient_profile.dart';
import 'package:book_ease/features/home/domain/errors/patient_home_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';

class _FakePatientHomeDataSource implements PatientHomeDataSource {
  _FakePatientHomeDataSource({this.error});

  final Object? error;

  @override
  Future<PatientHomeData> loadHomeData() async {
    if (error case final Object exception?) throw exception;
    return const PatientHomeData(
      profile: PatientProfile(
        fullName: 'Patient',
        imageUrl: '',
        role: 'patient',
      ),
      specialties: HomeSectionData(value: []),
      featuredDoctors: HomeSectionData(value: []),
      upcomingAppointment: HomeSectionData(value: null),
    );
  }
}

void main() {
  test('returns remote data unchanged', () async {
    final repository = PatientHomeRepositoryImpl(_FakePatientHomeDataSource());

    final data = await repository.loadHomeData();

    expect(data.profile.fullName, 'Patient');
    expect(data.specialties.value, isEmpty);
  });

  test('maps Firebase failures to a safe home error', () async {
    final repository = PatientHomeRepositoryImpl(
      _FakePatientHomeDataSource(
        error: FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
        ),
      ),
    );

    await expectLater(
      repository.loadHomeData(),
      throwsA(
        isA<PatientHomeException>().having(
          (error) => error.message,
          'message',
          'Home data could not be loaded. Please try again.',
        ),
      ),
    );
  });
}
