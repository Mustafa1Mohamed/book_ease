import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/errors/doctor_profile_exception.dart';
import '../../domain/repositories/doctor_profile_repository.dart';
import 'doctor_profile_state.dart';

class DoctorProfileCubit extends Cubit<DoctorProfileState> {
  DoctorProfileCubit(this._repository) : super(const DoctorProfileInitial());

  final DoctorProfileRepository _repository;

  Future<void> load() async {
    emit(const DoctorProfileLoading());
    try {
      emit(DoctorProfileLoaded(profile: await _repository.getOwnProfile()));
    } on DoctorProfileException catch (error) {
      emit(DoctorProfileFailure(error.message));
    } on Exception catch (error, stackTrace) {
      debugPrint('Doctor profile failed to load: $error\n$stackTrace');
      emit(
        const DoctorProfileFailure(
          'Your doctor profile could not be loaded. Please retry.',
        ),
      );
    }
  }

  Future<void> save({
    required String fullName,
    required String phoneNumber,
    required double? consultationFee,
    required String biography,
    required int? yearsExperience,
    required String clinicName,
    required String clinicAddress,
  }) async {
    final current = state;
    if (current is! DoctorProfileLoaded ||
        current.isSaving ||
        current.isUploadingImage) {
      return;
    }
    if (fullName.trim().isEmpty) {
      emit(
        current.copyWith(
          errorMessage: 'Enter your full name.',
          successMessage: null,
        ),
      );
      return;
    }
    emit(
      current.copyWith(
        isSaving: true,
        errorMessage: null,
        successMessage: null,
      ),
    );
    try {
      final profile = await _repository.updateProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
        consultationFee: consultationFee,
        biography: biography,
        yearsExperience: yearsExperience,
        clinicName: clinicName,
        clinicAddress: clinicAddress,
      );
      emit(
        DoctorProfileLoaded(profile: profile, successMessage: 'Profile saved.'),
      );
    } on DoctorProfileException catch (error) {
      emit(
        current.copyWith(
          isSaving: false,
          errorMessage: error.message,
          successMessage: null,
        ),
      );
    } on Exception catch (error, stackTrace) {
      debugPrint('Doctor profile update failed: $error\n$stackTrace');
      emit(
        current.copyWith(
          isSaving: false,
          errorMessage: 'Your profile could not be saved. Please try again.',
          successMessage: null,
        ),
      );
    }
  }

  Future<void> uploadProfileImage() async {
    final current = state;
    if (current is! DoctorProfileLoaded ||
        current.isUploadingImage ||
        current.isSaving) {
      return;
    }
    emit(
      current.copyWith(
        isUploadingImage: true,
        uploadProgress: 0,
        errorMessage: null,
        successMessage: null,
      ),
    );
    try {
      final profile = await _repository.pickAndUploadProfileImage(
        onProgress: (progress) {
          final latest = state;
          if (latest is DoctorProfileLoaded && latest.isUploadingImage) {
            emit(
              latest.copyWith(uploadProgress: progress.clamp(0, 1).toDouble()),
            );
          }
        },
      );
      final latest = state;
      if (latest is DoctorProfileLoaded) {
        emit(
          latest.copyWith(
            profile: profile,
            isUploadingImage: false,
            uploadProgress: 0,
            successMessage: profile == null ? null : 'Profile photo updated.',
          ),
        );
      }
    } on DoctorProfileException catch (error) {
      emit(
        current.copyWith(
          isUploadingImage: false,
          uploadProgress: 0,
          errorMessage: error.message,
          successMessage: null,
        ),
      );
    } on Exception catch (error, stackTrace) {
      debugPrint('Doctor profile photo upload failed: $error\n$stackTrace');
      emit(
        current.copyWith(
          isUploadingImage: false,
          uploadProgress: 0,
          errorMessage:
              'Your profile photo could not be uploaded. Please try again.',
          successMessage: null,
        ),
      );
    }
  }
}
