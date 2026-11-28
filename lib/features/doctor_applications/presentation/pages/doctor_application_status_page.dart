import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/entities/doctor_application.dart';
import '../cubit/doctor_application_cubit.dart';
import '../cubit/doctor_application_state.dart';

class DoctorApplicationStatusPage extends StatelessWidget {
  const DoctorApplicationStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.doctorApplicationTitle)),
      body: BlocBuilder<DoctorApplicationCubit, DoctorApplicationState>(
        builder: (context, state) => switch (state) {
          DoctorApplicationState(isLoading: true) => const Center(
            child: CircularProgressIndicator(),
          ),
          DoctorApplicationState(errorMessage: final message?)
              when message.isNotEmpty =>
            _Failure(message: message),
          DoctorApplicationState() => _ApplicationStatusContent(state: state),
        },
      ),
    );
  }
}

class _ApplicationStatusContent extends StatelessWidget {
  const _ApplicationStatusContent({required this.state});

  final DoctorApplicationState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final application = state.application;
    final message = switch (application?.status) {
      DoctorApplicationStatus.pending => l10n.doctorApplicationPending,
      DoctorApplicationStatus.approved => l10n.doctorApplicationApproved,
      DoctorApplicationStatus.rejected => l10n.doctorApplicationRejected,
      DoctorApplicationStatus.unknown => l10n.adminDoctorApplicationRetry,
      null => l10n.doctorApplicationNoApplication,
    };
    return ListView(
      padding: EdgeInsets.all(20.w),
      children: [
        Card(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  switch (application?.status) {
                    DoctorApplicationStatus.approved => Icons.verified_rounded,
                    DoctorApplicationStatus.rejected => Icons.cancel_outlined,
                    DoctorApplicationStatus.pending => Icons.pending_actions,
                    _ => Icons.medical_services_outlined,
                  },
                  size: 38,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(height: 12.h),
                Text(message, style: Theme.of(context).textTheme.titleLarge),
                if (application != null) ...[
                  SizedBox(height: 16.h),
                  _Detail(
                    label: l10n.doctorApplicationSpecialty,
                    value: application.specialtyName,
                  ),
                  _Detail(
                    label: l10n.doctorApplicationQualification,
                    value: application.qualification,
                  ),
                  _Detail(
                    label: l10n.doctorApplicationSubmittedOn,
                    value: _formatDate(context, application.submittedAt),
                  ),
                  if (application.reviewedAt != null)
                    _Detail(
                      label: l10n.doctorApplicationReviewedOn,
                      value: _formatDate(context, application.reviewedAt),
                    ),
                  if (application.rejectionReason.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Text(
                      l10n.doctorApplicationRejectionReason,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    SizedBox(height: 4.h),
                    Text(application.rejectionReason),
                  ],
                ],
              ],
            ),
          ),
        ),
        SizedBox(height: 16.h),
        if (application == null ||
            application.status == DoctorApplicationStatus.rejected)
          FilledButton.icon(
            onPressed: () async {
              final submitted = await context.pushNamed<bool>(
                AppRouter.doctorApplicationForm,
              );
              if (submitted == true && context.mounted) {
                await context.read<DoctorApplicationCubit>().loadStatus();
              }
            },
            icon: const Icon(Icons.assignment_outlined),
            label: Text(
              application == null
                  ? l10n.doctorApplicationStart
                  : l10n.doctorApplicationResubmit,
            ),
          ),
        if (application?.status == DoctorApplicationStatus.approved)
          FilledButton.icon(
            onPressed: () => context.goNamed(AppRouter.doctorDashboard),
            icon: const Icon(Icons.dashboard_rounded),
            label: Text(l10n.doctorApplicationGoDashboard),
          ),
      ],
    );
  }

  String _formatDate(BuildContext context, DateTime? date) {
    if (date == null) return '—';
    return MaterialLocalizations.of(context).formatMediumDate(date);
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: 8.h),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130.w,
          child: Text(label, style: Theme.of(context).textTheme.labelMedium),
        ),
        Expanded(child: Text(value.isEmpty ? '—' : value)),
      ],
    ),
  );
}

class _Failure extends StatelessWidget {
  const _Failure({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            SizedBox(height: 12.h),
            FilledButton(
              onPressed: context.read<DoctorApplicationCubit>().loadStatus,
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
