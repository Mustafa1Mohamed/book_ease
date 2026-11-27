import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../domain/entities/admin_patient.dart';

class AdminPatientCard extends StatelessWidget {
  const AdminPatientCard({super.key, required this.patient, this.onTap});

  final AdminPatient patient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final registrationDate = patient.createdAt == null
        ? null
        : DateFormat.yMMMd(l10n.localeName)
              .format(patient.createdAt!.toLocal());

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26.r,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (patient.email.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        patient.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    // if (patient.phoneNumber.isNotEmpty) ...[
                    //   SizedBox(height: 3.h),
                    //   Text(
                    //     patient.phoneNumber,
                    //     maxLines: 1,
                    //     overflow: TextOverflow.ellipsis,
                    //   ),
                    // ],
                    if (registrationDate != null) ...[
                      SizedBox(height: 5.h),
                      Text(
                        l10n.adminPatientRegistered(registrationDate),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
