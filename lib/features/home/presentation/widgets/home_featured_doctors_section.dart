import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/entities/featured_doctor.dart';
import 'featured_doctor_card.dart';
import 'home_section_empty.dart';
import 'home_section_header.dart';

class HomeFeaturedDoctorsSection extends StatelessWidget {
  const HomeFeaturedDoctorsSection({
    super.key,
    required this.doctors,
    required this.searchQuery,
    required this.onSeeAll,
    required this.hasError,
    required this.onRetry,
  });

  final List<FeaturedDoctor> doctors;
  final String searchQuery;
  final VoidCallback onSeeAll;
  final bool hasError;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final query = searchQuery.trim().toLowerCase();
    final visible = doctors
        .where(
          (doctor) =>
              doctor.fullName.toLowerCase().contains(query) ||
              doctor.specialtyName.toLowerCase().contains(query) ||
              doctor.specialtyNameAr.toLowerCase().contains(query),
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(
          title: 'Featured doctors',
          actionLabel: 'See all',
          onAction: onSeeAll,
        ),
        SizedBox(height: 12.h),
        if (hasError)
          HomeSectionEmpty(
            message: 'Could not load featured doctors.',
            onRetry: onRetry,
          )
        else if (visible.isEmpty)
          HomeSectionEmpty(
            message: query.isEmpty
                ? 'Featured doctors will appear here when available.'
                : 'No doctors match your search.',
          )
        else
          SizedBox(
            height: 174.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: visible.length,
              separatorBuilder: (_, _) => SizedBox(width: 12.w),
              itemBuilder: (_, index) =>
                  FeaturedDoctorCard(doctor: visible[index]),
            ),
          ),
      ],
    );
  }
}
