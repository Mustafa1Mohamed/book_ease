import 'package:equatable/equatable.dart';

import '../../domain/entities/admin_specialty.dart';

enum SpecialtyListFilter { all, active, inactive }

class AdminSpecialtiesState extends Equatable {
  const AdminSpecialtiesState({
    this.specialties = const [],
    this.query = '',
    this.filter = SpecialtyListFilter.all,
    this.isLoading = true,
    this.isSaving = false,
    this.isMutating = false,
    this.isCountLoading = false,
    this.doctorCount,
    this.countSpecialtyId,
    this.loadError,
    this.mutationError,
    this.countError,
  });

  final List<AdminSpecialty> specialties;
  final String query;
  final SpecialtyListFilter filter;
  final bool isLoading;
  final bool isSaving;
  final bool isMutating;
  final bool isCountLoading;
  final int? doctorCount;
  final String? countSpecialtyId;
  final String? loadError;
  final String? mutationError;
  final String? countError;

  List<AdminSpecialty> get visibleSpecialties {
    final normalizedQuery = query.trim().toLowerCase();
    return specialties
        .where((specialty) {
          final matchesFilter = switch (filter) {
            SpecialtyListFilter.all => true,
            SpecialtyListFilter.active => specialty.isActive,
            SpecialtyListFilter.inactive => !specialty.isActive,
          };
          final matchesQuery =
              normalizedQuery.isEmpty ||
              specialty.name.toLowerCase().contains(normalizedQuery) ||
              specialty.nameAr.toLowerCase().contains(normalizedQuery);
          return matchesFilter && matchesQuery;
        })
        .toList(growable: false);
  }

  AdminSpecialtiesState copyWith({
    List<AdminSpecialty>? specialties,
    String? query,
    SpecialtyListFilter? filter,
    bool? isLoading,
    bool? isSaving,
    bool? isMutating,
    bool? isCountLoading,
    int? doctorCount,
    String? countSpecialtyId,
    String? loadError,
    String? mutationError,
    String? countError,
    bool clearLoadError = false,
    bool clearMutationError = false,
    bool clearCountError = false,
    bool clearDoctorCount = false,
  }) => AdminSpecialtiesState(
    specialties: specialties ?? this.specialties,
    query: query ?? this.query,
    filter: filter ?? this.filter,
    isLoading: isLoading ?? this.isLoading,
    isSaving: isSaving ?? this.isSaving,
    isMutating: isMutating ?? this.isMutating,
    isCountLoading: isCountLoading ?? this.isCountLoading,
    doctorCount: clearDoctorCount ? null : doctorCount ?? this.doctorCount,
    countSpecialtyId: countSpecialtyId ?? this.countSpecialtyId,
    loadError: clearLoadError ? null : loadError ?? this.loadError,
    mutationError: clearMutationError
        ? null
        : mutationError ?? this.mutationError,
    countError: clearCountError ? null : countError ?? this.countError,
  );

  @override
  List<Object?> get props => [
    specialties,
    query,
    filter,
    isLoading,
    isSaving,
    isMutating,
    isCountLoading,
    doctorCount,
    countSpecialtyId,
    loadError,
    mutationError,
    countError,
  ];
}
