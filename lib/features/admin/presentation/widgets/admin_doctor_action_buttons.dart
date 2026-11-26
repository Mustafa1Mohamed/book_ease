import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../domain/entities/admin_doctor.dart';
import '../../domain/entities/admin_doctor_action.dart';

class AdminDoctorActionButtons extends StatelessWidget {
  const AdminDoctorActionButtons({
    super.key,
    required this.doctor,
    required this.isLoading,
    required this.onAction,
  });

  final AdminDoctor doctor;
  final bool isLoading;
  final ValueChanged<AdminDoctorAction> onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final actions = AdminDoctorActionPolicy.actionsFor(doctor);
    return Wrap(
      spacing: 10.w,
      runSpacing: 8.h,
      children: [
        for (final action in actions)
          FilledButton.icon(
            onPressed: isLoading ? null : () => onAction(action),
            icon: isLoading
                ? SizedBox(
                    width: 16.w,
                    height: 16.w,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(_icon(action)),
            label: Text(_label(action, l10n)),
          ),
      ],
    );
  }

  String _label(AdminDoctorAction action, AppLocalizations l10n) =>
      switch (action) {
        AdminDoctorAction.approve => l10n.adminDoctorApprove,
        AdminDoctorAction.reject => l10n.adminDoctorReject,
        AdminDoctorAction.suspend => l10n.adminDoctorSuspend,
        AdminDoctorAction.restore => l10n.adminDoctorRestore,
      };

  IconData _icon(AdminDoctorAction action) => switch (action) {
    AdminDoctorAction.approve => Icons.verified_rounded,
    AdminDoctorAction.reject => Icons.block_rounded,
    AdminDoctorAction.suspend => Icons.pause_circle_outline_rounded,
    AdminDoctorAction.restore => Icons.restore_rounded,
  };
}
