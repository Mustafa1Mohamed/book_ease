import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../cubit/patient_home_cubit.dart';
import '../cubit/patient_home_state.dart';
import 'home_error_view.dart';
import 'home_loading_view.dart';
import 'patient_home_content.dart';

class PatientHomeTabContent extends StatelessWidget {
  const PatientHomeTabContent({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onNotificationsTap,
    required this.onSeeAll,
    required this.onBookAppointment,
    required this.onRefresh,
  });

  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onNotificationsTap;
  final VoidCallback onSeeAll;
  final VoidCallback onBookAppointment;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientHomeCubit, PatientHomeState>(
      builder: (context, state) {
        return switch (state) {
          PatientHomeLoaded(
            :final data,
            :final isRefreshing,
            :final refreshError,
          ) =>
            PatientHomeContent(
              data: data,
              searchController: searchController,
              searchQuery: searchQuery,
              isRefreshing: isRefreshing,
              refreshError: refreshError,
              onSearchChanged: onSearchChanged,
              onClearSearch: onClearSearch,
              onNotificationsTap: onNotificationsTap,
              onSeeAll: onSeeAll,
              onBookAppointment: onBookAppointment,
              onRefresh: onRefresh,
            ),
          PatientHomeFailure(:final message) => HomeErrorView(
            message: message,
            onRetry: onRefresh,
          ),
          _ => const HomeLoadingView(),
        };
      },
    );
  }
}
