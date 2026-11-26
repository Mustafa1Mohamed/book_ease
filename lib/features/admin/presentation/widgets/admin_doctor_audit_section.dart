import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../domain/entities/admin_doctor_audit_event.dart';
import '../cubit/admin_doctor_details_state.dart';
import 'admin_doctor_audit_card.dart';

class AdminDoctorAuditSection extends StatelessWidget {
  const AdminDoctorAuditSection({
    super.key,
    required this.state,
    required this.retryAvailable,
    required this.onLoadMore,
    required this.onRetry,
  });

  final AdminDoctorDetailsState state;
  final bool retryAvailable;
  final VoidCallback onLoadMore;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.adminDoctorAuditHistory,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        if (state.auditHasError && retryAvailable)
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(l10n.adminDoctorAuditUnavailable),
          )
        else if (state.auditHasError)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            child: Text(l10n.adminDoctorAuditUnavailable),
          )
        else if (state.auditEvents.isEmpty && !state.isAuditLoading)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            child: Text(l10n.adminDoctorAuditEmpty),
          ),
        for (final AdminDoctorAuditEvent event in state.auditEvents)
          AdminDoctorAuditCard(event: event),
        if (state.isAuditLoading)
          const Center(child: CircularProgressIndicator()),
        if (state.auditHasMore && !state.isAuditLoading)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: onLoadMore,
              child: Text(l10n.adminDoctorsLoadMore),
            ),
          ),
      ],
    );
  }
}
