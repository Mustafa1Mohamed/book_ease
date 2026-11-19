import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/app_user.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileFailure extends ProfileState {
  const ProfileFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ProfileLoaded extends ProfileState {
  const ProfileLoaded({
    required this.user,
    this.isSaving = false,
    this.isUploadingImage = false,
    this.uploadProgress = 0,
    this.errorMessage,
    this.successMessage,
  });

  final AppUser user;
  final bool isSaving;
  final bool isUploadingImage;
  final double uploadProgress;
  final String? errorMessage;
  final String? successMessage;

  ProfileLoaded copyWith({
    AppUser? user,
    bool? isSaving,
    bool? isUploadingImage,
    double? uploadProgress,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return ProfileLoaded(
      user: user ?? this.user,
      isSaving: isSaving ?? this.isSaving,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage: clearSuccess
          ? null
          : successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [
    user,
    isSaving,
    isUploadingImage,
    uploadProgress,
    errorMessage,
    successMessage,
  ];
}
