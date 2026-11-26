import 'package:equatable/equatable.dart';

import '../../domain/entities/admin_doctor.dart';
import '../../domain/entities/admin_doctor_filter.dart';

class AdminDoctorListState extends Equatable {
  const AdminDoctorListState({
    this.doctors = const [],
    this.specialties = const [],
    this.filter = AdminDoctorFilter.all,
    this.search = '',
    this.specialtyId = '',
    this.cursor,
    this.hasMore = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasError = false,
    this.specialtiesUnavailable = false,
  });

  final List<AdminDoctor> doctors;
  final List<AdminDoctorSpecialty> specialties;
  final AdminDoctorFilter filter;
  final String search;
  final String specialtyId;
  final AdminDoctorCursor? cursor;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasError;
  final bool specialtiesUnavailable;

  AdminDoctorListState copyWith({
    List<AdminDoctor>? doctors,
    List<AdminDoctorSpecialty>? specialties,
    AdminDoctorFilter? filter,
    String? search,
    String? specialtyId,
    AdminDoctorCursor? cursor,
    bool clearCursor = false,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasError,
    bool? specialtiesUnavailable,
  }) => AdminDoctorListState(
    doctors: doctors ?? this.doctors,
    specialties: specialties ?? this.specialties,
    filter: filter ?? this.filter,
    search: search ?? this.search,
    specialtyId: specialtyId ?? this.specialtyId,
    cursor: clearCursor ? null : cursor ?? this.cursor,
    hasMore: hasMore ?? this.hasMore,
    isLoading: isLoading ?? this.isLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    hasError: hasError ?? this.hasError,
    specialtiesUnavailable:
        specialtiesUnavailable ?? this.specialtiesUnavailable,
  );

  @override
  List<Object?> get props => [
    doctors,
    specialties,
    filter,
    search,
    specialtyId,
    cursor,
    hasMore,
    isLoading,
    isLoadingMore,
    hasError,
    specialtiesUnavailable,
  ];
}
