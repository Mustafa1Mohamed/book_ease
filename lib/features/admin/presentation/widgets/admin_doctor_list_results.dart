import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../cubit/admin_doctor_list_cubit.dart';
import '../cubit/admin_doctor_list_state.dart';
import 'admin_doctor_card.dart';

class AdminDoctorListResults extends StatelessWidget {
  const AdminDoctorListResults({
    super.key,
    required this.state,
    required this.cubit,
  });

  final AdminDoctorListState state;
  final AdminDoctorListCubit cubit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (state.isLoading && state.doctors.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(36),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.hasError && state.doctors.isEmpty) {
      return _RetryView(
        message: l10n.adminDoctorsLoadError,
        onRetry: cubit.load,
      );
    }
    if (state.doctors.isEmpty) {
      return Column(
        children: [
          Padding(
            padding: EdgeInsets.all(36.w),
            child: Center(child: Text(l10n.adminDoctorsEmpty)),
          ),
          if (state.hasMore)
            TextButton(
              onPressed: state.isLoadingMore ? null : cubit.loadMore,
              child: state.isLoadingMore
                  ? const CircularProgressIndicator()
                  : Text(l10n.adminDoctorsLoadMore),
            ),
        ],
      );
    }
    return Column(
      children: [
        if (state.hasError)
          _Notice(
            message: l10n.adminDoctorsLoadError,
            color: Theme.of(context).colorScheme.error,
          ),
        if (state.isLoading) const LinearProgressIndicator(),
        for (final doctor in state.doctors)
          AdminDoctorCard(
            doctor: doctor,
            onTap: () => context.pushNamed(
              'admin-doctor-details',
              pathParameters: {'doctorId': doctor.id},
            ),
          ),
        if (state.hasMore)
          Center(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: FilledButton.tonal(
                onPressed: state.isLoadingMore ? null : cubit.loadMore,
                child: state.isLoadingMore
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.adminDoctorsLoadMore),
              ),
            ),
          ),
      ],
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.message, required this.color});

  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: EdgeInsets.only(bottom: 12.h),
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Text(message, style: TextStyle(color: color)),
  );
}

class _RetryView extends StatelessWidget {
  const _RetryView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.all(32.w),
    child: Column(
      children: [
        Text(message, textAlign: TextAlign.center),
        SizedBox(height: 12.h),
        OutlinedButton(
          onPressed: onRetry,
          child: Text(AppLocalizations.of(context).retry),
        ),
      ],
    ),
  );
}
