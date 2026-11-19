import 'package:equatable/equatable.dart';

import 'explore_sort.dart';

class ExploreFilters extends Equatable {
  const ExploreFilters({
    this.specialtyId,
    this.availableOnly = false,
    this.sort = ExploreSort.none,
  });

  final String? specialtyId;
  final bool availableOnly;
  final ExploreSort sort;

  ExploreFilters copyWith({
    String? specialtyId,
    bool clearSpecialty = false,
    bool? availableOnly,
    ExploreSort? sort,
  }) {
    return ExploreFilters(
      specialtyId: clearSpecialty ? null : specialtyId ?? this.specialtyId,
      availableOnly: availableOnly ?? this.availableOnly,
      sort: sort ?? this.sort,
    );
  }

  @override
  List<Object?> get props => [specialtyId, availableOnly, sort];
}
