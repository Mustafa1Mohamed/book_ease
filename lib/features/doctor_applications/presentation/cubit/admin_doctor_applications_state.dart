import 'package:equatable/equatable.dart';

import '../../domain/entities/doctor_application.dart';
import '../../domain/entities/doctor_application_page.dart';

class AdminDoctorApplicationsState extends Equatable {
  const AdminDoctorApplicationsState({
    this.applications = const [],
    this.specialties = const [],
    this.status = 'pending',
    this.specialtyId = '',
    this.search = '',
    this.cursor,
    this.hasMore = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasError = false,
    this.errorMessage,
  });

  final List<DoctorApplication> applications;
  final List<DoctorApplicationSpecialty> specialties;
  final String status;
  final String specialtyId;
  final String search;
  final String? cursor;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasError;
  final String? errorMessage;

  AdminDoctorApplicationsState copyWith({
    List<DoctorApplication>? applications,
    List<DoctorApplicationSpecialty>? specialties,
    String? status,
    String? specialtyId,
    String? search,
    String? cursor,
    bool clearCursor = false,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasError,
    String? errorMessage,
    bool clearError = false,
  }) => AdminDoctorApplicationsState(
    applications: applications ?? this.applications,
    specialties: specialties ?? this.specialties,
    status: status ?? this.status,
    specialtyId: specialtyId ?? this.specialtyId,
    search: search ?? this.search,
    cursor: clearCursor ? null : cursor ?? this.cursor,
    hasMore: hasMore ?? this.hasMore,
    isLoading: isLoading ?? this.isLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    hasError: hasError ?? this.hasError,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [
    applications,
    specialties,
    status,
    specialtyId,
    search,
    cursor,
    hasMore,
    isLoading,
    isLoadingMore,
    hasError,
    errorMessage,
  ];
}
