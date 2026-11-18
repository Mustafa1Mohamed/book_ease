import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/entities/medical_specialty.dart';
import 'home_section_empty.dart';
import 'home_section_header.dart';
import 'medical_specialty_card.dart';

class HomeSpecialtiesSection extends StatelessWidget {
  const HomeSpecialtiesSection({
    super.key,
    required this.specialties,
    required this.searchQuery,
    required this.onSeeAll,
    required this.hasError,
    required this.onRetry,
  });

  final List<MedicalSpecialty> specialties;
  final String searchQuery;
  final VoidCallback onSeeAll;
  final bool hasError;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final visible = specialties
        .where(
          (specialty) => specialty.name.toLowerCase().contains(
            searchQuery.trim().toLowerCase(),
          ),
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(
          title: 'Specialties',
          actionLabel: 'See all',
          onAction: onSeeAll,
        ),
        SizedBox(height: 12.h),
        if (hasError)
          HomeSectionEmpty(
            message: 'Could not load specialties.',
            onRetry: onRetry,
          )
        else if (visible.isEmpty)
          HomeSectionEmpty(
            message: searchQuery.isEmpty
                ? 'Specialties will appear here when available.'
                : 'No specialties match your search.',
          )
        else
          SizedBox(
            height: 112.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: visible.length,
              separatorBuilder: (_, _) => SizedBox(width: 12.w),
              itemBuilder: (_, index) =>
                  MedicalSpecialtyCard(specialty: visible[index]),
            ),
          ),
      ],
    );
  }
}
