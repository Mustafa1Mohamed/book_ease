import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../domain/entities/admin_doctor_action.dart';

Future<String?> showAdminDoctorActionConfirmation(
  BuildContext context,
  AdminDoctorAction action,
) async {
  final l10n = AppLocalizations.of(context);
  final controller = TextEditingController();
  final requiresReason = AdminDoctorActionPolicy.reasonRequired(action);
  var reasonMissing = false;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) {
        final label = _actionLabel(action, l10n);
        final description = switch (action) {
          AdminDoctorAction.approve => l10n.adminDoctorConfirmApprove,
          AdminDoctorAction.reject => l10n.adminDoctorConfirmReject,
          AdminDoctorAction.suspend => l10n.adminDoctorConfirmSuspend,
          AdminDoctorAction.restore => l10n.adminDoctorConfirmRestore,
        };
        return AlertDialog(
          title: Text(label),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(description),
              if (requiresReason) ...[
                SizedBox(height: 14.h),
                TextField(
                  controller: controller,
                  maxLength: 500,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: l10n.adminDoctorActionReason,
                    errorText: reasonMissing
                        ? l10n.adminDoctorReasonRequired
                        : null,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                if (requiresReason && controller.text.trim().isEmpty) {
                  setState(() => reasonMissing = true);
                  return;
                }
                Navigator.pop(dialogContext, true);
              },
              child: Text(label),
            ),
          ],
        );
      },
    ),
  );
  final reason = confirmed == true ? controller.text : null;
  controller.dispose();
  return reason;
}

String _actionLabel(AdminDoctorAction action, AppLocalizations l10n) =>
    switch (action) {
      AdminDoctorAction.approve => l10n.adminDoctorApprove,
      AdminDoctorAction.reject => l10n.adminDoctorReject,
      AdminDoctorAction.suspend => l10n.adminDoctorSuspend,
      AdminDoctorAction.restore => l10n.adminDoctorRestore,
    };
