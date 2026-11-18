import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/entities/patient_home_data.dart';
import 'home_featured_doctors_section.dart';
import 'home_header.dart';
import 'home_search_field.dart';
import 'home_specialties_section.dart';
import 'home_upcoming_appointment_section.dart';

class PatientHomeContent extends StatelessWidget {
  const PatientHomeContent({
    super.key,
    required this.data,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onNotificationsTap,
    required this.onSeeAll,
    required this.onBookAppointment,
    required this.onRefresh,
    this.isRefreshing = false,
    this.refreshError,
  });

  final PatientHomeData data;
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onNotificationsTap;
  final VoidCallback onSeeAll;
  final VoidCallback onBookAppointment;
  final Future<void> Function() onRefresh;
  final bool isRefreshing;
  final String? refreshError;

  @override
  Widget build(BuildContext context) {
    final refreshError = this.refreshError;
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
        children: [
          HomeHeader(
            profile: data.profile,
            onNotificationsTap: onNotificationsTap,
          ),
          SizedBox(height: 24.h),
          HomeSearchField(
            controller: searchController,
            onChanged: onSearchChanged,
            onClear: onClearSearch,
          ),
          if (isRefreshing) ...[
            SizedBox(height: 12.h),
            const LinearProgressIndicator(),
          ],
          if (refreshError != null) ...[
            SizedBox(height: 12.h),
            Text(
              refreshError,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.error),
            ),
          ],
          SizedBox(height: 28.h),
          HomeSpecialtiesSection(
            specialties: data.specialties.value,
            searchQuery: searchQuery,
            onSeeAll: onSeeAll,
            hasError: data.specialties.hasError,
            onRetry: () => onRefresh(),
          ),
          SizedBox(height: 28.h),
          HomeFeaturedDoctorsSection(
            doctors: data.featuredDoctors.value,
            searchQuery: searchQuery,
            onSeeAll: onSeeAll,
            hasError: data.featuredDoctors.hasError,
            onRetry: () => onRefresh(),
          ),
          SizedBox(height: 28.h),
          HomeUpcomingAppointmentSection(
            appointment: data.upcomingAppointment.value,
            onBookAppointment: onBookAppointment,
            hasError: data.upcomingAppointment.hasError,
            onRetry: () => onRefresh(),
          ),
        ],
      ),
    );
  }
}
