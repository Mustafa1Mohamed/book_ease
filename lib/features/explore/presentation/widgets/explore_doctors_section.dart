import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../home/domain/entities/featured_doctor.dart';
import '../../../home/presentation/widgets/home_section_empty.dart';
import '../../../home/presentation/widgets/home_section_header.dart';
import 'explore_doctor_card.dart';

class ExploreDoctorsSection extends StatelessWidget {
  const ExploreDoctorsSection({
    super.key,
    required this.doctors,
    required this.hasError,
    required this.query,
    required this.hasFilters,
    required this.onRetry,
  });

  final List<FeaturedDoctor> doctors;
  final bool hasError;
  final String query;
  final bool hasFilters;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(title: 'Doctors (${doctors.length})'),
        SizedBox(height: 12.h),
        if (hasError)
          HomeSectionEmpty(message: 'Could not load doctors.', onRetry: onRetry)
        else if (doctors.isEmpty)
          HomeSectionEmpty(
            message: query.isNotEmpty
                ? 'No doctors match "$query".'
                : hasFilters
                ? 'No doctors match these filters.'
                : 'No doctors are available yet.',
          )
        else
          for (final doctor in doctors) ...[
            ExploreDoctorCard(doctor: doctor),
            SizedBox(height: 10.h),
          ],
        if (!hasError && doctors.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: Text(
              'Doctor details and appointment booking are coming soon.',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ),
      ],
    );
  }
}
