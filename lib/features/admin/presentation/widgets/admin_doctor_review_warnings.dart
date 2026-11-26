import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../domain/entities/admin_doctor.dart';

class AdminDoctorReviewWarnings extends StatelessWidget {
  const AdminDoctorReviewWarnings({super.key, required this.doctor});

  final AdminDoctor doctor;

  @override
  Widget build(BuildContext context) {
    if (!doctor.needsReview) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        _Warning(message: l10n.adminDoctorNeedsReviewMessage),
        for (final warning in doctor.warnings)
          _Warning(message: _label(warning, l10n)),
      ],
    );
  }

  String _label(
    AdminDoctorWarning warning,
    AppLocalizations l10n,
  ) => switch (warning) {
    AdminDoctorWarning.missingUser => l10n.adminDoctorMissingUser,
    AdminDoctorWarning.missingDoctorProfile => l10n.adminDoctorMissingProfile,
    AdminDoctorWarning.userRoleMismatch => l10n.adminDoctorRoleMismatch,
    AdminDoctorWarning.identityMissing => l10n.adminDoctorIdentityMissing,
    AdminDoctorWarning.identityLegacy => l10n.adminDoctorIdentityLegacy,
    AdminDoctorWarning.identityMismatch => l10n.adminDoctorIdentityMismatch,
    AdminDoctorWarning.identityAmbiguous => l10n.adminDoctorIdentityAmbiguous,
    AdminDoctorWarning.approvalStatusMissing ||
    AdminDoctorWarning.administrativeStatusMissing =>
      l10n.adminDoctorStatusMissing,
    AdminDoctorWarning.invalidStatus => l10n.adminDoctorInvalidStatus,
    _ => l10n.adminDoctorIncompleteProfile,
  };
}

class _Warning extends StatelessWidget {
  const _Warning({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: EdgeInsets.only(top: 10.h),
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Text(message),
  );
}
