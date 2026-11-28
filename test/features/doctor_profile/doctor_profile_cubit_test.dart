import 'package:book_ease/features/auth/domain/entities/doctor_lifecycle_status.dart';
import 'package:book_ease/features/doctor_profile/domain/entities/doctor_profile.dart';
import 'package:book_ease/features/doctor_profile/domain/errors/doctor_profile_exception.dart';
import 'package:book_ease/features/doctor_profile/domain/repositories/doctor_profile_repository.dart';
import 'package:book_ease/features/doctor_profile/presentation/cubit/doctor_profile_cubit.dart';
import 'package:book_ease/features/doctor_profile/presentation/cubit/doctor_profile_state.dart';
import 'package:flutter_test/flutter_test.dart';

final _profile = DoctorProfile(
  uid: 'doctor-1',
  doctorId: 'profile-1',
  fullName: 'Dr. Example',
  email: 'doctor@example.com',
  phoneNumber: '123',
  profileImageUrl: '',
  specialtyId: 'specialty-1',
  specialtyName: 'Family medicine',
  consultationFee: 50,
  biography: 'Experienced doctor',
  qualifications: const ['MD'],
  yearsExperience: 8,
  languages: const ['English'],
  clinicName: 'BookEase Clinic',
  clinicAddress: 'Main Street',
  lifecycle: DoctorLifecycleStatus.fromDoctorData({
    'approvalStatus': 'approved',
    'administrativeStatus': 'active',
  }),
);

class _FakeDoctorProfileRepository implements DoctorProfileRepository {
  bool failLoad = false;
  bool failSave = false;
  bool failPhoto = false;
  int saveCalls = 0;
  int photoCalls = 0;

  @override
  Future<DoctorProfile> getOwnProfile() async {
    if (failLoad) throw const DoctorProfileException('Profile missing.');
    return _profile;
  }

  @override
  Future<DoctorProfile> updateProfile({
    required String fullName,
    required String phoneNumber,
    required double? consultationFee,
    required String biography,
    required int? yearsExperience,
    required String clinicName,
    required String clinicAddress,
  }) async {
    saveCalls++;
    if (failSave) throw const DoctorProfileException('Save failed.');
    return DoctorProfile(
      uid: _profile.uid,
      doctorId: _profile.doctorId,
      fullName: fullName,
      email: _profile.email,
      phoneNumber: phoneNumber,
      profileImageUrl: _profile.profileImageUrl,
      specialtyId: _profile.specialtyId,
      specialtyName: _profile.specialtyName,
      consultationFee: consultationFee,
      biography: biography,
      qualifications: _profile.qualifications,
      yearsExperience: yearsExperience,
      languages: _profile.languages,
      clinicName: clinicName,
      clinicAddress: clinicAddress,
      lifecycle: _profile.lifecycle,
    );
  }

  @override
  Future<DoctorProfile?> pickAndUploadProfileImage({
    required void Function(double progress) onProgress,
  }) async {
    photoCalls++;
    onProgress(0.5);
    if (failPhoto) throw const DoctorProfileException('Upload failed.');
    onProgress(1);
    return _profile;
  }
}

void main() {
  test('loads the resolved own profile', () async {
    final repository = _FakeDoctorProfileRepository();
    final cubit = DoctorProfileCubit(repository);

    await cubit.load();

    expect(cubit.state, isA<DoctorProfileLoaded>());
    expect((cubit.state as DoctorProfileLoaded).profile.doctorId, 'profile-1');
  });

  test('shows missing profile errors safely', () async {
    final repository = _FakeDoctorProfileRepository()..failLoad = true;
    final cubit = DoctorProfileCubit(repository);

    await cubit.load();

    expect(cubit.state, isA<DoctorProfileFailure>());
    expect((cubit.state as DoctorProfileFailure).message, 'Profile missing.');
  });

  test('saves permitted fields and refreshes the loaded profile', () async {
    final repository = _FakeDoctorProfileRepository();
    final cubit = DoctorProfileCubit(repository);
    await cubit.load();

    await cubit.save(
      fullName: 'Dr. Updated',
      phoneNumber: '555',
      consultationFee: 75,
      biography: 'Updated bio',
      yearsExperience: 10,
      clinicName: 'Updated Clinic',
      clinicAddress: 'Updated Address',
    );

    expect(repository.saveCalls, 1);
    final state = cubit.state as DoctorProfileLoaded;
    expect(state.profile.fullName, 'Dr. Updated');
    expect(state.profile.specialtyName, 'Family medicine');
    expect(state.successMessage, 'Profile saved.');
  });

  test('prevents duplicate saves while saving', () async {
    final repository = _FakeDoctorProfileRepository();
    final cubit = DoctorProfileCubit(repository);
    await cubit.load();

    await Future.wait([
      cubit.save(
        fullName: 'Dr. One',
        phoneNumber: '1',
        consultationFee: 50,
        biography: 'Bio',
        yearsExperience: 8,
        clinicName: 'Clinic',
        clinicAddress: 'Address',
      ),
      cubit.save(
        fullName: 'Dr. Two',
        phoneNumber: '2',
        consultationFee: 60,
        biography: 'Bio 2',
        yearsExperience: 9,
        clinicName: 'Clinic',
        clinicAddress: 'Address',
      ),
    ]);

    expect(repository.saveCalls, 1);
  });

  test('preserves the loaded photo and reports upload failure', () async {
    final repository = _FakeDoctorProfileRepository()..failPhoto = true;
    final cubit = DoctorProfileCubit(repository);
    await cubit.load();

    await cubit.uploadProfileImage();

    expect(repository.photoCalls, 1);
    final state = cubit.state as DoctorProfileLoaded;
    expect(state.profile.profileImageUrl, '');
    expect(state.errorMessage, 'Upload failed.');
  });
}
