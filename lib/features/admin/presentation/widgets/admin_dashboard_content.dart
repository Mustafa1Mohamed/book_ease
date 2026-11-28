import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/admin_dashboard_stats.dart';
import 'admin_stat_card.dart';

class AdminDashboardContent extends StatelessWidget {
  const AdminDashboardContent({
    super.key,
    required this.stats,
    required this.isLoading,
    required this.isRefreshing,
    required this.refreshFailed,
    required this.onRefresh,
  });

  final AdminDashboardStats? stats;
  final bool isLoading;
  final bool isRefreshing;
  final bool refreshFailed;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = [
      (
        label: l10n.adminTotalPatients,
        value: stats?.totalPatients,
        icon: Icons.people_alt_rounded,
        color: AppColors.primary,
        onTap: () => context.pushNamed(AppRouter.adminPatients),
      ),
      (
        label: l10n.adminTotalDoctors,
        value: stats?.totalDoctors,
        icon: Icons.medical_services_rounded,
        color: AppColors.secondary,
        onTap: () => context.pushNamed(AppRouter.adminDoctors),
      ),
      (
        label: l10n.adminPendingDoctors,
        value: stats?.pendingDoctors,
        icon: Icons.pending_actions_rounded,
        color: AppColors.warning,
        onTap: () => context.pushNamed(
          AppRouter.adminDoctors,
          queryParameters: const {'filter': 'pending'},
        ),
      ),
      (
        label: l10n.adminApprovedDoctors,
        value: stats?.approvedDoctors,
        icon: Icons.verified_rounded,
        color: AppColors.success,
        onTap: () => context.pushNamed(
          AppRouter.adminDoctors,
          queryParameters: const {'filter': 'approved'},
        ),
      ),
      (
        label: l10n.adminTotalSpecialties,
        value: stats?.totalSpecialties,
        icon: Icons.category_rounded,
        color: AppColors.primaryDark,
        onTap: null,
      ),
      (
        label: l10n.adminTotalAppointments,
        value: stats?.totalAppointments,
        icon: Icons.calendar_month_rounded,
        color: AppColors.secondary,
        onTap: null,
      ),
      (
        label: l10n.adminUpcomingAppointments,
        value: stats?.upcomingAppointments,
        icon: Icons.event_available_rounded,
        color: AppColors.primary,
        onTap: null,
      ),
      (
        label: l10n.adminCompletedAppointments,
        value: stats?.completedAppointments,
        icon: Icons.task_alt_rounded,
        color: AppColors.success,
        onTap: null,
      ),
    ];

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth < 1120
              ? constraints.maxWidth
              : 1120.0;
          final horizontalPadding = 40.w;
          final availableWidth = maxWidth - horizontalPadding;
          final columns = constraints.maxWidth >= 960
              ? 4
              : constraints.maxWidth >= 620
              ? 3
              : 2;
          const spacing = 16.0;
          final cardWidth =
              (availableWidth - spacing * (columns - 1)) / columns;
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.adminDashboardOverview,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        l10n.adminDashboardSubtitle,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(height: 16.h),
                      Wrap(
                        spacing: 12.w,
                        runSpacing: 8.h,
                        children: [
                          FilledButton.icon(
                            onPressed: () =>
                                context.pushNamed(AppRouter.adminDoctors),
                            icon: const Icon(Icons.medical_services_rounded),
                            label: Text(l10n.adminDoctorsTitle),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => context.pushNamed(
                              AppRouter.adminDoctorApplications,
                            ),
                            icon: const Icon(Icons.assignment_ind_outlined),
                            label: Text(l10n.adminDoctorApplications),
                          ),
                        ],
                      ),
                      if (isRefreshing) ...[
                        SizedBox(height: 18.h),
                        const LinearProgressIndicator(),
                      ],
                      if (refreshFailed ||
                          (stats?.hasUnavailableMetrics ?? false)) ...[
                        SizedBox(height: 18.h),
                        _DashboardNotice(
                          message: refreshFailed
                              ? l10n.adminDashboardRefreshError
                              : l10n.adminDashboardPartialError,
                        ),
                      ],
                      SizedBox(height: 24.h),
                      Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: [
                          for (final metric in metrics)
                            SizedBox(
                              width: cardWidth,
                              child: AdminStatCard(
                                label: metric.label,
                                value: metric.value,
                                unavailableLabel: l10n.adminMetricUnavailable,
                                icon: metric.icon,
                                accentColor: metric.color,
                                localeName: l10n.localeName,
                                isLoading: isLoading,
                                onTap: metric.onTap,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DashboardNotice extends StatelessWidget {
  const _DashboardNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: colorScheme.error),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
