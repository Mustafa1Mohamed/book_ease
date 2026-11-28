import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../home/presentation/widgets/home_avatar.dart';
import '../../domain/entities/doctor_application.dart';
import '../cubit/admin_doctor_applications_cubit.dart';

class AdminDoctorApplicationDetailsPage extends StatelessWidget {
  const AdminDoctorApplicationDetailsPage({
    required this.applicationId,
    super.key,
  });

  final String applicationId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminDoctorApplicationDetails)),
      body:
          BlocBuilder<
            AdminDoctorApplicationDetailsCubit,
            AdminDoctorApplicationDetailsState
          >(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.errorMessage != null || state.application == null) {
                return _Error(
                  message: l10n.adminDoctorApplicationDetailsLoadError,
                  onRetry: () => context
                      .read<AdminDoctorApplicationDetailsCubit>()
                      .load(applicationId),
                );
              }
              return _DetailsContent(state: state);
            },
          ),
    );
  }
}

class _DetailsContent extends StatelessWidget {
  const _DetailsContent({required this.state});

  final AdminDoctorApplicationDetailsState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final application = state.application!;
    final account = state.applicantAccount;
    final cubit = context.read<AdminDoctorApplicationDetailsCubit>();
    final statusLabel = switch (application.status) {
      DoctorApplicationStatus.pending => l10n.adminDoctorApplicationsPending,
      DoctorApplicationStatus.approved => l10n.adminDoctorApplicationsApproved,
      DoctorApplicationStatus.rejected => l10n.adminDoctorApplicationsRejected,
      DoctorApplicationStatus.unknown => '—',
    };
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth > 900 ? 860.0 : constraints.maxWidth;
        return Center(
          child: SizedBox(
            width: width,
            child: ListView(
              padding: EdgeInsets.all(20.w),
              children: [
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.adminDoctorApplicationAccount,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            HomeAvatar(
                              imageUrl:
                                  account?.profileImageUrl ??
                                  application.profileImageUrl,
                              radius: 32,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    account?.fullName.isNotEmpty == true
                                        ? account!.fullName
                                        : application.applicantName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                  Text(
                                    account?.email.isNotEmpty == true
                                        ? account!.email
                                        : application.applicantEmail,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        _Detail(
                          l10n.adminDoctorApplicationUid,
                          application.applicantUid,
                        ),
                        _Detail(
                          l10n.doctorApplicationPhone,
                          account?.phoneNumber.isNotEmpty == true
                              ? account!.phoneNumber
                              : application.applicantPhone,
                        ),
                        _Detail(
                          l10n.adminDoctorApplicationRole,
                          account?.role ?? '—',
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.adminDoctorApplicationDetails,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: 12.h),
                        _Detail(
                          l10n.doctorApplicationSpecialty,
                          application.specialtyName,
                        ),
                        _Detail(
                          l10n.doctorApplicationQualification,
                          application.qualification,
                        ),
                        _Detail(
                          l10n.doctorApplicationExperience,
                          application.experienceYears.toString(),
                        ),
                        _Detail(
                          l10n.doctorApplicationFee,
                          application.consultationFee.toStringAsFixed(2),
                        ),
                        _Detail(
                          l10n.doctorApplicationClinicAddress,
                          application.clinicAddress,
                        ),
                        _Detail(l10n.doctorApplicationBio, application.bio),
                        _Detail(
                          l10n.doctorApplicationSubmittedOn,
                          _date(context, application.submittedAt),
                        ),
                        _Detail(l10n.doctorApplicationStatus, statusLabel),
                        if (application.reviewedAt != null)
                          _Detail(
                            l10n.doctorApplicationReviewedOn,
                            _date(context, application.reviewedAt),
                          ),
                        if (application.reviewerUid.isNotEmpty)
                          _Detail(
                            l10n.adminDoctorApplicationReviewer,
                            application.reviewerUid,
                          ),
                        if (application.rejectionReason.isNotEmpty)
                          _Detail(
                            l10n.doctorApplicationRejectionReason,
                            application.rejectionReason,
                          ),
                      ],
                    ),
                  ),
                ),
                if (state.history.length > 1) ...[
                  SizedBox(height: 12.h),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.adminDoctorApplicationHistory,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          SizedBox(height: 8.h),
                          for (final previous in state.history)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                '${previous.specialtyName} · ${_statusLabel(l10n, previous.status)}',
                              ),
                              subtitle: Text(
                                _date(context, previous.submittedAt),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (state.reviewError != null) ...[
                  SizedBox(height: 12.h),
                  Text(
                    _reviewErrorLabel(l10n, state.reviewErrorCode),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (application.status == DoctorApplicationStatus.pending) ...[
                  SizedBox(height: 16.h),
                  if (state.isReviewing)
                    const Center(child: CircularProgressIndicator())
                  else
                    Wrap(
                      spacing: 12.w,
                      runSpacing: 12.h,
                      children: [
                        FilledButton.icon(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: Text(l10n.adminDoctorApplicationApprove),
                                content: Text(application.applicantName),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext, false),
                                    child: Text(l10n.cancel),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext, true),
                                    child: Text(
                                      l10n.adminDoctorApplicationsApproved,
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (confirm != true || !context.mounted) return;
                            final reviewed = await cubit.review(approve: true);
                            if (!context.mounted) return;
                            if (reviewed) Navigator.of(context).pop(true);
                          },
                          icon: const Icon(Icons.verified_outlined),
                          label: Text(l10n.adminDoctorApplicationApprove),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _reject(context, cubit, l10n),
                          icon: const Icon(Icons.cancel_outlined),
                          label: Text(l10n.adminDoctorApplicationReject),
                        ),
                      ],
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _reject(
    BuildContext context,
    AdminDoctorApplicationDetailsCubit cubit,
    AppLocalizations l10n,
  ) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => _RejectApplicationDialog(l10n: l10n),
    );
    if (reason == null || !context.mounted) return;
    final reviewed = await cubit.review(approve: false, reason: reason);
    if (!context.mounted) return;
    if (reviewed) Navigator.of(context).pop(true);
  }

  static String _statusLabel(
    AppLocalizations l10n,
    DoctorApplicationStatus status,
  ) => switch (status) {
    DoctorApplicationStatus.pending => l10n.adminDoctorApplicationsPending,
    DoctorApplicationStatus.approved => l10n.adminDoctorApplicationsApproved,
    DoctorApplicationStatus.rejected => l10n.adminDoctorApplicationsRejected,
    DoctorApplicationStatus.unknown => '—',
  };

  static String _date(BuildContext context, DateTime? value) => value == null
      ? '—'
      : MaterialLocalizations.of(context).formatMediumDate(value);
}

class _RejectApplicationDialog extends StatefulWidget {
  const _RejectApplicationDialog({required this.l10n});

  final AppLocalizations l10n;

  @override
  State<_RejectApplicationDialog> createState() =>
      _RejectApplicationDialogState();
}

class _RejectApplicationDialogState extends State<_RejectApplicationDialog> {
  late final TextEditingController _reasonController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!mounted) return;
    final reason = _reasonController.text.trim();
    if (reason.length < 5 || reason.length > 500) {
      setState(() {
        _errorMessage = widget.l10n.adminDoctorApplicationReasonRequired;
      });
      return;
    }
    Navigator.of(context).pop(reason);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.l10n.adminDoctorApplicationReject),
    content: TextField(
      controller: _reasonController,
      minLines: 2,
      maxLines: 5,
      decoration: InputDecoration(
        labelText: widget.l10n.adminDoctorApplicationReasonPrompt,
        errorText: _errorMessage,
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(widget.l10n.cancel),
      ),
      FilledButton(
        onPressed: _submit,
        child: Text(widget.l10n.adminDoctorApplicationReject),
      ),
    ],
  );
}

class _Detail extends StatelessWidget {
  const _Detail(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: 8.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        SizedBox(height: 2.h),
        Text(value.isEmpty ? '—' : value),
      ],
    ),
  );
}

class _Error extends StatelessWidget {
  const _Error({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          SizedBox(height: 12.h),
          FilledButton(
            onPressed: onRetry,
            child: Text(AppLocalizations.of(context).retry),
          ),
        ],
      ),
    ),
  );
}

String _reviewErrorLabel(AppLocalizations l10n, String? code) => switch (code) {
  'permission-denied' => l10n.adminDoctorApplicationPermissionDenied,
  'unauthenticated' => l10n.adminDoctorApplicationAuthenticationRequired,
  'not-found' => l10n.adminDoctorApplicationNotFound,
  'already-exists' ||
  'failed-precondition' => l10n.adminDoctorApplicationConflict,
  'specialty-unavailable' => l10n.adminDoctorApplicationSpecialtyUnavailable,
  'invalid-argument' ||
  'invalid-data' => l10n.adminDoctorApplicationInvalidData,
  'unavailable' ||
  'deadline-exceeded' => l10n.adminDoctorApplicationNetworkError,
  _ => l10n.adminDoctorApplicationRetry,
};
