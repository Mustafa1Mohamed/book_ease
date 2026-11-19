import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../domain/errors/profile_exception.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_image_picker_data_source.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(
    this._remoteDataSource,
    this._imagePickerDataSource,
  );

  static const _maxImageBytes = 5 * 1024 * 1024;
  final ProfileRemoteDataSource _remoteDataSource;
  final ProfileImagePickerDataSource _imagePickerDataSource;

  @override
  Future<AppUser> getCurrentProfile() async {
    try {
      return await _remoteDataSource.getCurrentProfile();
    } on ProfileException {
      rethrow;
    } on FirebaseException {
      throw const ProfileException(
        'Your profile could not be loaded. Please try again.',
      );
    }
  }

  @override
  Future<AppUser> updateProfile({
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      return await _remoteDataSource.updateProfile(
        fullName: fullName.trim(),
        phoneNumber: phoneNumber.trim(),
      );
    } on ProfileException {
      rethrow;
    } on FirebaseException {
      throw const ProfileException(
        'Your profile could not be saved. Please try again.',
      );
    }
  }

  @override
  Future<AppUser?> pickAndUploadProfileImage({
    required void Function(double progress) onProgress,
  }) async {
    try {
      final image = await _imagePickerDataSource.pickImage();
      if (image == null) return null;
      final bytes = await image.readAsBytes();
      if (bytes.isEmpty || bytes.lengthInBytes >= _maxImageBytes) {
        throw const ProfileException(
          'Choose an image smaller than 5 MB.',
        );
      }
      return await _remoteDataSource.uploadProfileImage(
        bytes: bytes,
        onProgress: onProgress,
      );
    } on ProfileException {
      rethrow;
    } on FirebaseException {
      throw const ProfileException(
        'Your profile photo could not be uploaded. Please try again.',
      );
    }
  }
}
