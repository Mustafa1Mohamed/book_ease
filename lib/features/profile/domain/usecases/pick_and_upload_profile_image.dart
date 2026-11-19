import '../../../auth/domain/entities/app_user.dart';
import '../repositories/profile_repository.dart';

class PickAndUploadProfileImage {
  const PickAndUploadProfileImage(this._repository);

  final ProfileRepository _repository;

  Future<AppUser?> call({
    required void Function(double progress) onProgress,
  }) {
    return _repository.pickAndUploadProfileImage(onProgress: onProgress);
  }
}
