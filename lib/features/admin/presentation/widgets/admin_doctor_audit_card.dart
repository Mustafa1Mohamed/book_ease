import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../domain/entities/admin_doctor_audit_event.dart';

class AdminDoctorAuditCard extends StatelessWidget {
  const AdminDoctorAuditCard({super.key, required this.event});

  final AdminDoctorAuditEvent event;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final action = switch (event.action) {
      'approve' => l10n.adminDoctorActionApprove,
      'reject' => l10n.adminDoctorActionReject,
      'suspend' => l10n.adminDoctorActionSuspend,
      'restore' => l10n.adminDoctorActionRestore,
      _ => event.action,
    };
    final timestamp = event.createdAt == null
        ? ''
        : DateFormat.yMMMd(l10n.localeName)
              .add_jm()
              .format(event.createdAt!.toLocal());
    return Card(
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(action, style: Theme.of(context).textTheme.titleSmall),
            if (timestamp.isNotEmpty) Text(timestamp),
            SizedBox(height: 6.h),
            Text('${l10n.adminDoctorActor}: ${event.actorUid}'),
            Text('${l10n.adminDoctorProfileId}: ${event.doctorProfileId}'),
            Text(
              '${l10n.adminDoctorPreviousStatus}: ${_statusLabel(event.previousApprovalStatus, event.previousAdministrativeStatus, l10n)}',
            ),
            Text(
              '${l10n.adminDoctorNewStatus}: ${_statusLabel(event.newApprovalStatus, event.newAdministrativeStatus, l10n)}',
            ),
            if (event.reason.isNotEmpty)
              Text('${l10n.adminDoctorReason}: ${event.reason}'),
          ],
        ),
      ),
    );
  }

  String _statusLabel(
    String approval,
    String administrative,
    AppLocalizations l10n,
  ) {
    final approvalLabel = switch (approval) {
      'pending' => l10n.adminDoctorsPending,
      'approved' => l10n.adminDoctorsApproved,
      'rejected' => l10n.adminDoctorsRejected,
      _ => approval,
    };
    final administrativeLabel = switch (administrative) {
      'active' => l10n.adminDoctorActive,
      'suspended' => l10n.adminDoctorsSuspended,
      _ => administrative,
    };
    return '$approvalLabel / $administrativeLabel';
  }
}
