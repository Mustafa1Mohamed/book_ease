import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/entities/explore_filters.dart';
import '../../domain/entities/explore_sort.dart';
import '../../../home/domain/entities/medical_specialty.dart';

class ExploreActiveFilters extends StatelessWidget {
  const ExploreActiveFilters({
    super.key,
    required this.filters,
    required this.specialties,
    required this.onRemoveSpecialty,
    required this.onRemoveAvailability,
    required this.onRemoveSort,
  });

  final ExploreFilters filters;
  final List<MedicalSpecialty> specialties;
  final VoidCallback onRemoveSpecialty;
  final VoidCallback onRemoveAvailability;
  final VoidCallback onRemoveSort;

  @override
  Widget build(BuildContext context) {
    final selected = specialties.where(
      (specialty) => specialty.id == filters.specialtyId,
    );
    final specialtyName = selected.isEmpty ? 'Specialty' : selected.first.name;
    final sortLabel = switch (filters.sort) {
      ExploreSort.none => null,
      ExploreSort.highestRating => 'Top rated',
      ExploreSort.lowestFee => 'Lowest fee',
    };
    if (filters.specialtyId == null &&
        !filters.availableOnly &&
        sortLabel == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 4.h,
        children: [
          if (filters.specialtyId != null)
            InputChip(label: Text(specialtyName), onDeleted: onRemoveSpecialty),
          if (filters.availableOnly)
            InputChip(
              label: const Text('Available'),
              onDeleted: onRemoveAvailability,
            ),
          if (sortLabel != null)
            InputChip(label: Text(sortLabel), onDeleted: onRemoveSort),
        ],
      ),
    );
  }
}
