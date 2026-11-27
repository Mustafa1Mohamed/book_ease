import 'package:equatable/equatable.dart';

import '../../domain/entities/admin_patient.dart';
import '../../domain/entities/admin_patient_page.dart';

class AdminPatientListState extends Equatable {
  const AdminPatientListState({
    this.patients = const [],
    this.search = '',
    this.cursor,
    this.hasMore = false,
    this.isLoading = false,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.hasError = false,
    this.loadMoreHasError = false,
  });

  final List<AdminPatient> patients;
  final String search;
  final AdminPatientCursor? cursor;
  final bool hasMore;
  final bool isLoading;
  final bool isRefreshing;
  final bool isLoadingMore;
  final bool hasError;
  final bool loadMoreHasError;

  AdminPatientListState copyWith({
    List<AdminPatient>? patients,
    String? search,
    AdminPatientCursor? cursor,
    bool clearCursor = false,
    bool? hasMore,
    bool? isLoading,
    bool? isRefreshing,
    bool? isLoadingMore,
    bool? hasError,
    bool? loadMoreHasError,
  }) => AdminPatientListState(
    patients: patients ?? this.patients,
    search: search ?? this.search,
    cursor: clearCursor ? null : cursor ?? this.cursor,
    hasMore: hasMore ?? this.hasMore,
    isLoading: isLoading ?? this.isLoading,
    isRefreshing: isRefreshing ?? this.isRefreshing,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    hasError: hasError ?? this.hasError,
    loadMoreHasError: loadMoreHasError ?? this.loadMoreHasError,
  );

  @override
  List<Object?> get props => [
    patients,
    search,
    cursor,
    hasMore,
    isLoading,
    isRefreshing,
    isLoadingMore,
    hasError,
    loadMoreHasError,
  ];
}
