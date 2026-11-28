import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../profile/data/datasources/profile_image_picker_data_source.dart';
import '../../../profile/data/datasources/profile_remote_data_source.dart';
import '../../domain/entities/doctor_profile.dart';
import '../../domain/errors/doctor_profile_exception.dart';
import '../../domain/repositories/doctor_profile_repository.dart';
import '../datasources/doctor_profile_remote_data_source.dart';

class DoctorProfileRepositoryImpl implements DoctorProfileRepository {
  const DoctorProfileRepositoryImpl(
    this._remoteDataSource,
    this._imagePickerDataSource,
    this._profileRemoteDataSource,
  );

  static const _maxImageBytes = 5 * 1024 * 1024;
  final DoctorProfileRemoteDataSource _remoteDataSource;
  final ProfileImagePickerDataSource _imagePickerDataSource;
  final ProfileRemoteDataSource _profileRemoteDataSource;

  @override
  Future<DoctorProfile> getOwnProfile() => _remoteDataSource.getOwnProfile();

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
    try {
      return await _remoteDataSource.updateProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
        consultationFee: consultationFee,
        biography: biography,
        yearsExperience: yearsExperience,
        clinicName: clinicName,
        clinicAddress: clinicAddress,
      );
    } on DoctorProfileException {
      rethrow;
    } on FirebaseException catch (_) {
      throw const DoctorProfileException(
        'Your profile could not be saved. Please try again.',
      );
    }
  }

  @override
  Future<DoctorProfile?> pickAndUploadProfileImage({
    required void Function(double progress) onProgress,
  }) async {
    try {
      final image = await _imagePickerDataSource.pickImage();
      if (image == null) return null;
      final bytes = await image.readAsBytes();
      if (bytes.isEmpty) {
        throw const DoctorProfileException('Choose a valid image.');
      }
      if (bytes.lengthInBytes > _maxImageBytes) {
        throw const DoctorProfileException(
          'Choose an image smaller than 5 MB.',
        );
      }
      await _profileRemoteDataSource.uploadProfileImage(
        bytes: bytes,
        onProgress: onProgress,
      );
      return await _remoteDataSource.getOwnProfile();
    } on DoctorProfileException {
      rethrow;
    } on StorageException catch (_) {
      throw const DoctorProfileException(
        'Your profile photo could not be uploaded.',
      );
    } on FirebaseException catch (_) {
      throw const DoctorProfileException(
        'Your profile photo could not be uploaded. Please try again.',
      );
    }
  }
}
