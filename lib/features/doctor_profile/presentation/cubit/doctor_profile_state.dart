import '../../domain/entities/doctor_profile.dart';

sealed class DoctorProfileState {
  const DoctorProfileState();
}

class DoctorProfileInitial extends DoctorProfileState {
  const DoctorProfileInitial();
}

class DoctorProfileLoading extends DoctorProfileState {
  const DoctorProfileLoading();
}

class DoctorProfileLoaded extends DoctorProfileState {
  const DoctorProfileLoaded({
    required this.profile,
    this.isSaving = false,
    this.isUploadingImage = false,
    this.uploadProgress = 0,
    this.errorMessage,
    this.successMessage,
  });

  final DoctorProfile profile;
  final bool isSaving;
  final bool isUploadingImage;
  final double uploadProgress;
  final String? errorMessage;
  final String? successMessage;

  DoctorProfileLoaded copyWith({
    DoctorProfile? profile,
    bool? isSaving,
    bool? isUploadingImage,
    double? uploadProgress,
    String? errorMessage,
    String? successMessage,
  }) => DoctorProfileLoaded(
    profile: profile ?? this.profile,
    isSaving: isSaving ?? this.isSaving,
    isUploadingImage: isUploadingImage ?? this.isUploadingImage,
    uploadProgress: uploadProgress ?? this.uploadProgress,
    errorMessage: errorMessage,
    successMessage: successMessage,
  );
}

class DoctorProfileFailure extends DoctorProfileState {
  const DoctorProfileFailure(this.message);

  final String message;
}
