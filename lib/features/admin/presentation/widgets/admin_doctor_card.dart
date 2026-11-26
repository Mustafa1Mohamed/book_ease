import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../domain/entities/admin_doctor.dart';

class AdminDoctorCard extends StatelessWidget {
  const AdminDoctorCard({super.key, required this.doctor, required this.onTap});

  final AdminDoctor doctor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final status = doctor.lifecycle.approvalStatus.name;
    final statusLabel = switch (status) {
      'pending' => l10n.adminDoctorsPending,
      'approved' => l10n.adminDoctorsApproved,
      'rejected' => l10n.adminDoctorsRejected,
      _ => l10n.adminDoctorInvalidStatus,
    };
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28.r,
                backgroundImage: doctor.profileImageUrl.isEmpty
                    ? null
                    : NetworkImage(doctor.profileImageUrl),
                child: doctor.profileImageUrl.isEmpty
                    ? const Icon(Icons.person_outline_rounded)
                    : null,
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name.isEmpty
                          ? l10n.adminDoctorProfile
                          : doctor.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      doctor.email.isEmpty
                          ? l10n.adminDoctorEmail
                          : doctor.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 4.h,
                      children: [
                        _StatusChip(
                          label: statusLabel,
                          color: doctor.lifecycle.isValid
                              ? colorScheme.primary
                              : colorScheme.error,
                        ),
                        if (doctor.lifecycle.isSuspended)
                          _StatusChip(
                            label: l10n.adminDoctorsSuspended,
                            color: colorScheme.error,
                          ),
                        if (doctor.needsReview)
                          _StatusChip(
                            label: l10n.adminDoctorsNeedsReview,
                            color: colorScheme.tertiary,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Chip(
    label: Text(label),
    visualDensity: VisualDensity.compact,
    side: BorderSide(color: color.withValues(alpha: 0.25)),
    backgroundColor: color.withValues(alpha: 0.08),
    labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
  );
}
