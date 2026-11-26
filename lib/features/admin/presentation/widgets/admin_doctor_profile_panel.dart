import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../domain/entities/admin_doctor.dart';

class AdminDoctorProfilePanel extends StatelessWidget {
  const AdminDoctorProfilePanel({super.key, required this.doctor});

  final AdminDoctor doctor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: EdgeInsets.all(18.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32.r,
                  backgroundImage: doctor.profileImageUrl.isEmpty
                      ? null
                      : NetworkImage(doctor.profileImageUrl),
                  child: doctor.profileImageUrl.isEmpty
                      ? const Icon(Icons.person_outline_rounded)
                      : null,
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Text(
                    doctor.name.isEmpty ? l10n.adminDoctorProfile : doctor.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.adminDoctorProfile,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            _Field(label: l10n.adminDoctorEmail, value: doctor.email),
            _Field(label: l10n.adminDoctorPhone, value: doctor.phoneNumber),
            _Field(
              label: l10n.adminDoctorSpecialty,
              value: doctor.specialtyName.isNotEmpty
                  ? doctor.specialtyName
                  : doctor.specialtyId,
            ),
            _Field(
              label: l10n.adminDoctorFee,
              value: doctor.consultationFee?.toStringAsFixed(2) ?? '',
            ),
            _Field(label: l10n.adminDoctorBiography, value: doctor.biography),
            _Field(
              label: l10n.adminDoctorQualifications,
              value: doctor.qualifications.join(', '),
            ),
            _Field(
              label: l10n.adminDoctorExperience,
              value: doctor.yearsExperience?.toString() ?? '',
            ),
            _Field(label: l10n.adminDoctorClinic, value: doctor.clinicName),
            _Field(label: l10n.adminDoctorAddress, value: doctor.clinicAddress),
            Divider(height: 24.h),
            Text(
              l10n.adminDoctorIdentity,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            _Field(label: l10n.adminDoctorProfileId, value: doctor.id),
            _Field(label: l10n.adminDoctorUid, value: doctor.uid),
            _Field(
              label: l10n.adminDoctorApprovalStatus,
              value: _approvalLabel(doctor, l10n),
            ),
            _Field(
              label: l10n.adminDoctorAdministrativeStatus,
              value: _administrativeLabel(doctor, l10n),
            ),
          ],
        ),
      ),
    );
  }

  String _approvalLabel(AdminDoctor doctor, AppLocalizations l10n) =>
      switch (doctor.lifecycle.approvalStatus.name) {
        'pending' => l10n.adminDoctorsPending,
        'approved' => l10n.adminDoctorsApproved,
        'rejected' => l10n.adminDoctorsRejected,
        _ => l10n.adminDoctorInvalidStatus,
      };

  String _administrativeLabel(AdminDoctor doctor, AppLocalizations l10n) =>
      switch (doctor.lifecycle.administrativeStatus.name) {
        'active' => l10n.adminDoctorActive,
        'suspended' => l10n.adminDoctorsSuspended,
        _ => l10n.adminDoctorInvalidStatus,
      };
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: 7.h),
      child: Text('$label: $value'),
    );
  }
}
