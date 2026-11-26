import 'package:book_ease/features/home/data/models/featured_doctor_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps optional doctor details without inventing missing content', () {
    final doctor = FeaturedDoctorModel.fromMap(
      'doctor-1',
      {
        'approvalStatus': 'approved',
        'administrativeStatus': 'active',
        'fullName': 'Dr. Morgan Lee',
        'specialtyId': 'cardiology',
        'biography': 'Cardiologist with a patient-first approach.',
        'qualifications': ['MD', 'Board certified'],
        'yearsExperience': 12,
        'languages': ['English', 'French'],
        'clinicName': 'North Clinic',
        'clinicAddress': '12 Main Street',
        'consultationDurationMinutes': 30,
        'reviewCount': 42,
      },
      specialtyNamesById: const {'cardiology': 'Cardiology'},
    );

    expect(doctor, isNotNull);
    expect(doctor!.specialtyName, 'Cardiology');
    expect(doctor.biography, 'Cardiologist with a patient-first approach.');
    expect(doctor.qualifications, ['MD', 'Board certified']);
    expect(doctor.yearsExperience, 12);
    expect(doctor.languages, ['English', 'French']);
    expect(doctor.reviewCount, 42);
  });

  test('rejects malformed optional detail values safely', () {
    final doctor = FeaturedDoctorModel.fromMap('doctor-2', {
      'approvalStatus': 'approved',
      'administrativeStatus': 'active',
      'name': 'Dr. Avery',
      'qualifications': 'not a list',
      'yearsExperience': -3,
      'consultationDurationMinutes': 'unknown',
    }, specialtyNamesById: const {});

    expect(doctor, isNotNull);
    expect(doctor!.qualifications, isEmpty);
    expect(doctor.yearsExperience, isNull);
    expect(doctor.consultationDurationMinutes, isNull);
  });
}
