import '../../../auth/domain/entities/app_user.dart';

abstract interface class ProfileRepository {
  Future<AppUser> getCurrentProfile();

  Future<AppUser> updateProfile({
    required String fullName,
    required String phoneNumber,
  });

  Future<AppUser?> pickAndUploadProfileImage({
    required void Function(double progress) onProgress,
  });
}
