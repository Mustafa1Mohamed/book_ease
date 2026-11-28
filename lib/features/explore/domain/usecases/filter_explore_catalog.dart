import '../../../home/domain/entities/featured_doctor.dart';
import '../entities/explore_filters.dart';
import '../entities/explore_sort.dart';

class FilterExploreCatalog {
  const FilterExploreCatalog();

  List<FeaturedDoctor> call(
    List<FeaturedDoctor> doctors, {
    required String query,
    required ExploreFilters filters,
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    final result = doctors.where((doctor) {
      final matchesQuery =
          normalizedQuery.isEmpty ||
          doctor.fullName.toLowerCase().contains(normalizedQuery) ||
          doctor.specialtyName.toLowerCase().contains(normalizedQuery) ||
          doctor.specialtyNameAr.toLowerCase().contains(normalizedQuery);
      final matchesSpecialty =
          filters.specialtyId == null ||
          doctor.specialtyId == filters.specialtyId;
      final matchesAvailability =
          !filters.availableOnly || doctor.isAvailable == true;
      return matchesQuery && matchesSpecialty && matchesAvailability;
    }).toList();

    switch (filters.sort) {
      case ExploreSort.none:
        break;
      case ExploreSort.highestRating:
        result.sort((first, second) {
          final ratingOrder = _compareDescendingMissingLast(
            first.rating,
            second.rating,
          );
          return ratingOrder == 0 ? _compareNames(first, second) : ratingOrder;
        });
      case ExploreSort.lowestFee:
        result.sort((first, second) {
          final feeOrder = _comparePresentFirst(
            first.consultationFee,
            second.consultationFee,
          );
          return feeOrder == 0 ? _compareNames(first, second) : feeOrder;
        });
    }
    return result;
  }

  int _comparePresentFirst(double? first, double? second) {
    if (first == null) return second == null ? 0 : 1;
    if (second == null) return -1;
    return first.compareTo(second);
  }

  int _compareDescendingMissingLast(double? first, double? second) {
    if (first == null) return second == null ? 0 : 1;
    if (second == null) return -1;
    return second.compareTo(first);
  }

  int _compareNames(FeaturedDoctor first, FeaturedDoctor second) =>
      first.fullName.compareTo(second.fullName);
}
