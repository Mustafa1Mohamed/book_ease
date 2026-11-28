import 'package:equatable/equatable.dart';

import '../../domain/entities/doctor_application.dart';
import '../../domain/entities/doctor_application_page.dart';

class DoctorApplicationState extends Equatable {
  const DoctorApplicationState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.isSubmitted = false,
    this.isForm = false,
    this.application,
    this.specialties = const [],
    this.errorMessage,
  });

  final bool isLoading;
  final bool isSubmitting;
  final bool isSubmitted;
  final bool isForm;
  final DoctorApplication? application;
  final List<DoctorApplicationSpecialty> specialties;
  final String? errorMessage;

  DoctorApplicationState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    bool? isSubmitted,
    bool? isForm,
    DoctorApplication? application,
    List<DoctorApplicationSpecialty>? specialties,
    String? errorMessage,
    bool clearError = false,
  }) => DoctorApplicationState(
    isLoading: isLoading ?? this.isLoading,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    isSubmitted: isSubmitted ?? this.isSubmitted,
    isForm: isForm ?? this.isForm,
    application: application ?? this.application,
    specialties: specialties ?? this.specialties,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [
    isLoading,
    isSubmitting,
    isSubmitted,
    isForm,
    application,
    specialties,
    errorMessage,
  ];
}
