import '../entities/doctor_profile.dart';

abstract interface class DoctorProfileRepository {
  Future<DoctorProfile> getOwnProfile();

  Future<DoctorProfile> updateProfile({
    required String fullName,
    required String phoneNumber,
    required double? consultationFee,
    required String biography,
    required int? yearsExperience,
    required String clinicName,
    required String clinicAddress,
  });

  Future<DoctorProfile?> pickAndUploadProfileImage({
    required void Function(double progress) onProgress,
  });
}
