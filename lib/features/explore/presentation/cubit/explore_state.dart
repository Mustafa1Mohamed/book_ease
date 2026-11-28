import 'package:equatable/equatable.dart';

import '../../domain/entities/explore_catalog.dart';
import '../../domain/entities/explore_filters.dart';
import '../../domain/usecases/filter_explore_catalog.dart';
import '../../../home/domain/entities/featured_doctor.dart';
import '../../../home/domain/entities/medical_specialty.dart';

sealed class ExploreState extends Equatable {
  const ExploreState();

  @override
  List<Object?> get props => [];
}

class ExploreInitial extends ExploreState {
  const ExploreInitial();
}

class ExploreLoading extends ExploreState {
  const ExploreLoading();
}

class ExploreFailure extends ExploreState {
  const ExploreFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ExploreLoaded extends ExploreState {
  const ExploreLoaded({
    required this.catalog,
    this.query = '',
    this.filters = const ExploreFilters(),
    this.isRefreshing = false,
    this.refreshError,
  });

  final ExploreCatalog catalog;
  final String query;
  final ExploreFilters filters;
  final bool isRefreshing;
  final String? refreshError;

  List<FeaturedDoctor> get filteredDoctors => _filterExploreCatalog(
    catalog.doctors.value,
    query: query,
    filters: filters,
  );

  List<MedicalSpecialty> get matchingSpecialties {
    return catalog.specialties.value
        .where((specialty) => specialty.matches(query))
        .toList();
  }

  static const _filterExploreCatalog = FilterExploreCatalog();

  ExploreLoaded copyWith({
    ExploreCatalog? catalog,
    String? query,
    ExploreFilters? filters,
    bool? isRefreshing,
    String? refreshError,
    bool clearRefreshError = false,
  }) {
    return ExploreLoaded(
      catalog: catalog ?? this.catalog,
      query: query ?? this.query,
      filters: filters ?? this.filters,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      refreshError: clearRefreshError
          ? null
          : refreshError ?? this.refreshError,
    );
  }

  @override
  List<Object?> get props => [
    catalog,
    query,
    filters,
    isRefreshing,
    refreshError,
  ];
}
