import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../features/auth/presentation/cubit/auth_cubit.dart';
import '../cubit/admin_dashboard_cubit.dart';
import '../cubit/admin_dashboard_state.dart';
import '../widgets/admin_dashboard_content.dart';
import '../widgets/admin_dashboard_error_view.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textDirection = l10n.localeName.startsWith('ar')
        ? TextDirection.rtl
        : TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.adminDashboardTitle),
          actions: [
            IconButton(
              tooltip: l10n.signOut,
              onPressed: () => context.read<AuthCubit>().signOut(),
              icon: const Icon(Icons.logout_rounded),
            ),
            SizedBox(width: 8.w),
          ],
        ),
        body: BlocBuilder<AdminDashboardCubit, AdminDashboardState>(
          builder: (context, state) {
            final cubit = context.read<AdminDashboardCubit>();
            return switch (state) {
              AdminDashboardInitial() ||
              AdminDashboardLoading() => AdminDashboardContent(
                isLoading: true,
                isRefreshing: false,
                refreshFailed: false,
                onRefresh: cubit.load,
                stats: null,
              ),
              AdminDashboardFailure() => AdminDashboardErrorView(
                title: l10n.adminDashboardUnavailable,
                message: l10n.adminDashboardLoadError,
                retryLabel: l10n.retry,
                onRetry: cubit.load,
              ),
              AdminDashboardLoaded(
                :final stats,
                :final isRefreshing,
                :final refreshFailed,
              ) =>
                AdminDashboardContent(
                  stats: stats,
                  isLoading: false,
                  isRefreshing: isRefreshing,
                  refreshFailed: refreshFailed,
                  onRefresh: cubit.load,
                ),
            };
          },
        ),
      ),
    );
  }
}
