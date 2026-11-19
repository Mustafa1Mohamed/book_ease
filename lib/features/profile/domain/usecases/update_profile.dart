import '../../../auth/domain/entities/app_user.dart';
import '../repositories/profile_repository.dart';

class UpdateProfile {
  const UpdateProfile(this._repository);

  final ProfileRepository _repository;

  Future<AppUser> call({
    required String fullName,
    required String phoneNumber,
  }) {
    return _repository.updateProfile(
      fullName: fullName,
      phoneNumber: phoneNumber,
    );
  }
}
