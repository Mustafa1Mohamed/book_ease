import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/errors/profile_exception.dart';
import '../../domain/usecases/get_current_profile.dart';
import '../../domain/usecases/pick_and_upload_profile_image.dart';
import '../../domain/usecases/update_profile.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(
    this._getCurrentProfile,
    this._updateProfile,
    this._pickAndUploadProfileImage,
  ) : super(const ProfileInitial());

  final GetCurrentProfile _getCurrentProfile;
  final UpdateProfile _updateProfile;
  final PickAndUploadProfileImage _pickAndUploadProfileImage;

  Future<void> load() async {
    emit(const ProfileLoading());
    try {
      emit(ProfileLoaded(user: await _getCurrentProfile()));
    } on ProfileException catch (error) {
      emit(ProfileFailure(error.message));
    } on Exception catch (error, stackTrace) {
      debugPrint('Profile failed to load: $error\n$stackTrace');
      emit(
        const ProfileFailure('Your profile could not be loaded. Please retry.'),
      );
    }
  }

  Future<void> save({
    required String fullName,
    required String phoneNumber,
  }) async {
    final current = state;
    if (current is! ProfileLoaded ||
        current.isSaving ||
        current.isUploadingImage) {
      return;
    }
    if (fullName.trim().isEmpty) {
      emit(
        current.copyWith(
          errorMessage: 'Enter your full name.',
          clearSuccess: true,
        ),
      );
      return;
    }

    emit(
      current.copyWith(
        isSaving: true,
        clearError: true,
        clearSuccess: true,
      ),
    );
    try {
      final user = await _updateProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
      );
      if (state is ProfileLoaded) {
        emit(
          (state as ProfileLoaded).copyWith(
            user: user,
            isSaving: false,
            successMessage: 'Profile saved.',
          ),
        );
      }
    } on ProfileException catch (error) {
      _emitFailure(error.message);
    } on Exception catch (error, stackTrace) {
      debugPrint('Profile update failed: $error\n$stackTrace');
      _emitFailure('Your profile could not be saved. Please try again.');
    }
  }

  Future<void> uploadProfileImage() async {
    final current = state;
    if (current is! ProfileLoaded ||
        current.isUploadingImage ||
        current.isSaving) {
      return;
    }
    emit(
      current.copyWith(
        isUploadingImage: true,
        uploadProgress: 0,
        clearError: true,
        clearSuccess: true,
      ),
    );
    try {
      final user = await _pickAndUploadProfileImage(
        onProgress: (progress) {
          final latest = state;
          if (latest is ProfileLoaded && latest.isUploadingImage) {
            emit(
              latest.copyWith(
                uploadProgress: progress.clamp(0, 1).toDouble(),
              ),
            );
          }
        },
      );
      final latest = state;
      if (latest is ProfileLoaded) {
        emit(
          latest.copyWith(
            user: user ?? latest.user,
            isUploadingImage: false,
            uploadProgress: 0,
            successMessage: user == null ? null : 'Profile photo updated.',
          ),
        );
      }
    } on ProfileException catch (error) {
      _emitFailure(error.message, uploading: true);
    } on Exception catch (error, stackTrace) {
      debugPrint('Profile photo upload failed: $error\n$stackTrace');
      _emitFailure(
        'Your profile photo could not be uploaded. Please try again.',
        uploading: true,
      );
    }
  }

  void _emitFailure(String message, {bool uploading = false}) {
    final current = state;
    if (current is! ProfileLoaded) return;
    emit(
      current.copyWith(
        isSaving: false,
        isUploadingImage: uploading ? false : current.isUploadingImage,
        uploadProgress: uploading ? 0 : current.uploadProgress,
        errorMessage: message,
        clearSuccess: true,
      ),
    );
  }
}
