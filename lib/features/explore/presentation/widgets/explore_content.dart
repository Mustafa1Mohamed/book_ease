import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/entities/explore_catalog.dart';
import '../../domain/entities/explore_filters.dart';
import '../../domain/entities/explore_sort.dart';
import '../../../home/domain/entities/featured_doctor.dart';
import 'explore_doctors_section.dart';
import 'explore_header.dart';
import 'explore_specialties_section.dart';
import 'explore_filter_bar.dart';
import 'explore_search_panel.dart';

class ExploreContent extends StatelessWidget {
  const ExploreContent({
    super.key,
    required this.catalog,
    required this.query,
    required this.filters,
    required this.filteredDoctors,
    required this.searchController,
    required this.isRefreshing,
    required this.refreshError,
    required this.onQueryChanged,
    required this.onClearQuery,
    required this.onRefresh,
    required this.onSelectSpecialty,
    required this.onApplyFilters,
    required this.onSelectSort,
  });

  final ExploreCatalog catalog;
  final String query;
  final ExploreFilters filters;
  final List<FeaturedDoctor> filteredDoctors;
  final TextEditingController searchController;
  final bool isRefreshing;
  final String? refreshError;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClearQuery;
  final Future<void> Function() onRefresh;
  final ValueChanged<String?> onSelectSpecialty;
  final ValueChanged<ExploreFilters> onApplyFilters;
  final ValueChanged<ExploreSort> onSelectSort;

  @override
  Widget build(BuildContext context) {
    final doctors = catalog.doctors.value;
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
        children: [
          const ExploreHeader(),
          SizedBox(height: 20.h),
          ExploreSearchPanel(
            controller: searchController,
            onQueryChanged: onQueryChanged,
            onClearQuery: onClearQuery,
            isRefreshing: isRefreshing,
            refreshError: refreshError,
          ),
          ExploreSpecialtiesSection(
            specialties: catalog.specialties.value,
            selectedId: filters.specialtyId,
            query: query,
            hasError: catalog.specialties.hasError,
            onSelect: onSelectSpecialty,
            onRetry: () => onRefresh(),
          ),
          SizedBox(height: 22.h),
          ExploreFilterBar(
            catalog: catalog,
            filters: filters,
            doctors: doctors,
            onSelectSpecialty: onSelectSpecialty,
            onApplyFilters: onApplyFilters,
            onSelectSort: onSelectSort,
          ),
          ExploreDoctorsSection(
            doctors: filteredDoctors,
            hasError: catalog.doctors.hasError,
            query: query,
            hasFilters:
                filters.specialtyId != null ||
                filters.availableOnly ||
                filters.sort != ExploreSort.none,
            onRetry: () => onRefresh(),
          ),
        ],
      ),
    );
  }
}
