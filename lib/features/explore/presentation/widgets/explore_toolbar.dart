import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/entities/explore_filters.dart';
import '../../domain/entities/explore_sort.dart';
import '../../../home/domain/entities/featured_doctor.dart';
import '../../../home/domain/entities/medical_specialty.dart';
import 'explore_filter_sheet.dart';
import 'explore_sort_sheet.dart';

class ExploreToolbar extends StatelessWidget {
  const ExploreToolbar({
    super.key,
    required this.filters,
    required this.specialties,
    required this.doctors,
    required this.onApplyFilters,
    required this.onSelectSort,
  });

  final ExploreFilters filters;
  final List<MedicalSpecialty> specialties;
  final List<FeaturedDoctor> doctors;
  final ValueChanged<ExploreFilters> onApplyFilters;
  final ValueChanged<ExploreSort> onSelectSort;

  @override
  Widget build(BuildContext context) {
    final supportsAvailability = doctors.any(
      (doctor) => doctor.isAvailable != null,
    );
    final supportsRating = doctors.any((doctor) => doctor.rating != null);
    final supportsFee = doctors.any((doctor) => doctor.consultationFee != null);

    return Row(
      children: [
        Expanded(
          child: Text(
            'Browse doctors',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        OutlinedButton.icon(
          onPressed: () async {
            final result = await ExploreFilterSheet.show(
              context,
              filters: filters,
              specialties: specialties,
              supportsAvailability: supportsAvailability,
            );
            if (result != null) onApplyFilters(result);
          },
          icon: const Icon(Icons.tune_rounded),
          label: const Text('Filter'),
        ),
        SizedBox(width: 8.w),
        IconButton(
          tooltip: 'Sort doctors',
          onPressed: () async {
            final sort = await ExploreSortSheet.show(
              context,
              currentSort: filters.sort,
              supportsRating: supportsRating,
              supportsFee: supportsFee,
            );
            if (sort != null) onSelectSort(sort);
          },
          icon: const Icon(Icons.sort_rounded),
        ),
      ],
    );
  }
}
