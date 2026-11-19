import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../../home/domain/entities/medical_specialty.dart';
import '../../domain/entities/explore_filters.dart';
import 'explore_filter_actions.dart';
import 'explore_filter_options.dart';

class ExploreFilterSheet extends StatefulWidget {
  const ExploreFilterSheet({
    super.key,
    required this.filters,
    required this.specialties,
    required this.supportsAvailability,
  });

  final ExploreFilters filters;
  final List<MedicalSpecialty> specialties;
  final bool supportsAvailability;

  static Future<ExploreFilters?> show(
    BuildContext context, {
    required ExploreFilters filters,
    required List<MedicalSpecialty> specialties,
    required bool supportsAvailability,
  }) {
    return showModalBottomSheet<ExploreFilters>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ExploreFilterSheet(
        filters: filters,
        specialties: specialties,
        supportsAvailability: supportsAvailability,
      ),
    );
  }

  @override
  State<ExploreFilterSheet> createState() => _ExploreFilterSheetState();
}

class _ExploreFilterSheetState extends State<ExploreFilterSheet> {
  String? _specialtyId;
  bool _availableOnly = false;

  @override
  void initState() {
    super.initState();
    _specialtyId = widget.filters.specialtyId;
    _availableOnly = widget.filters.availableOnly;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter doctors',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16.h),
            ExploreFilterOptions(
              specialties: widget.specialties,
              specialtyId: _specialtyId,
              availableOnly: _availableOnly,
              supportsAvailability: widget.supportsAvailability,
              onSpecialtyChanged: (value) =>
                  setState(() => _specialtyId = value),
              onAvailabilityChanged: (value) =>
                  setState(() => _availableOnly = value),
            ),
            const SizedBox(height: 12),
            ExploreFilterActions(
              onCancel: () => Navigator.pop(context),
              onReset: () => Navigator.pop(context, const ExploreFilters()),
              onApply: () => Navigator.pop(
                context,
                widget.filters.copyWith(
                  specialtyId: _specialtyId,
                  clearSpecialty: _specialtyId == null,
                  availableOnly: _availableOnly,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
