import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/entities/explore_catalog.dart';
import '../../domain/entities/explore_filters.dart';
import '../../domain/entities/explore_sort.dart';
import '../../../home/domain/entities/featured_doctor.dart';
import 'explore_active_filters.dart';
import 'explore_toolbar.dart';

class ExploreFilterBar extends StatelessWidget {
  const ExploreFilterBar({
    super.key,
    required this.catalog,
    required this.filters,
    required this.doctors,
    required this.onSelectSpecialty,
    required this.onApplyFilters,
    required this.onSelectSort,
  });

  final ExploreCatalog catalog;
  final ExploreFilters filters;
  final List<FeaturedDoctor> doctors;
  final ValueChanged<String?> onSelectSpecialty;
  final ValueChanged<ExploreFilters> onApplyFilters;
  final ValueChanged<ExploreSort> onSelectSort;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExploreToolbar(
          filters: filters,
          specialties: catalog.specialties.value,
          doctors: doctors,
          onApplyFilters: onApplyFilters,
          onSelectSort: onSelectSort,
        ),
        ExploreActiveFilters(
          filters: filters,
          specialties: catalog.specialties.value,
          onRemoveSpecialty: () => onSelectSpecialty(null),
          onRemoveAvailability: () =>
              onApplyFilters(filters.copyWith(availableOnly: false)),
          onRemoveSort: () => onSelectSort(ExploreSort.none),
        ),
        SizedBox(height: 12.h),
      ],
    );
  }
}
