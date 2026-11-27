import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../domain/entities/admin_patient.dart';

class AdminPatientProfilePanel extends StatelessWidget {
  const AdminPatientProfilePanel({super.key, required this.patient});

  final AdminPatient patient;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 520;
                final identity = Row(
                  children: [
                    CircleAvatar(
                      radius: 34.r,
                      backgroundImage: patient.profileImageUrl.isEmpty
                          ? null
                          : NetworkImage(patient.profileImageUrl),
                      child: patient.profileImageUrl.isEmpty
                          ? const Icon(Icons.person_outline_rounded)
                          : null,
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patient.fullName.isEmpty
                                ? l10n.adminPatientNameUnavailable
                                : patient.fullName,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          if (patient.email.isNotEmpty)
                            Text(
                              patient.email,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                        ],
                      ),
                    ),
                  ],
                );
                final completeness = Column(
                  crossAxisAlignment: compact
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
                  children: [
                    Text(l10n.adminPatientProfileCompleteness),
                    Text(
                      l10n.adminPatientCompletenessPercent(
                        patient.profileCompleteness,
                      ),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                );
                return compact
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          identity,
                          SizedBox(height: 14.h),
                          completeness,
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(child: identity),
                          SizedBox(width: 16.w),
                          completeness,
                        ],
                      );
              },
            ),
            SizedBox(height: 18.h),
            const Divider(),
            // _PatientInfo(
            //   label: l10n.adminDoctorUid,
            //   value: patient.uid,
            //   icon: Icons.fingerprint_rounded,
            // ),
            _PatientInfo(
              label: l10n.adminDoctorEmail,
              value: patient.email,
              icon: Icons.email_outlined,
            ),
            _PatientInfo(
              label: l10n.adminDoctorPhone,
              value: patient.phoneNumber,
              icon: Icons.phone_outlined,
            ),
            _PatientInfo(
              label: l10n.adminPatientRole,
              value: l10n.adminPatientRoleValue,
              icon: Icons.verified_user_outlined,
            ),
            if (patient.createdAt != null)
              _PatientInfo(
                label: l10n.adminPatientAccountCreated,
                value: DateFormat.yMMMd(l10n.localeName)
                    .add_jm()
                    .format(patient.createdAt!.toLocal()),
                icon: Icons.calendar_today_outlined,
              ),
            if (patient.updatedAt != null)
              _PatientInfo(
                label: l10n.adminPatientLastUpdated,
                value: DateFormat.yMMMd(l10n.localeName)
                    .add_jm()
                    .format(patient.updatedAt!.toLocal()),
                icon: Icons.update_rounded,
              ),
          ],
        ),
      ),
    );
  }
}

class _PatientInfo extends StatelessWidget {
  const _PatientInfo({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: 11.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19.w, color: Theme.of(context).colorScheme.primary),
          SizedBox(width: 10.w),
          SizedBox(
            width: 150.w,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }
}
