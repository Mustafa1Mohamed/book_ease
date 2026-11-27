import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../domain/entities/admin_patient.dart';
import '../cubit/admin_patient_details_state.dart';
import 'admin_patient_appointments_section.dart';
import 'admin_patient_profile_panel.dart';

class AdminPatientDetailsContent extends StatelessWidget {
  const AdminPatientDetailsContent({
    super.key,
    required this.patient,
    required this.state,
    required this.onRetryAppointments,
    required this.onLoadMoreAppointments,
  });

  final AdminPatient patient;
  final AdminPatientDetailsState state;
  final VoidCallback onRetryAppointments;
  final VoidCallback onLoadMoreAppointments;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.extentAfter < 260 &&
            state.appointmentsHasMore &&
            !state.isLoadingMoreAppointments &&
            !state.appointmentsHasError) {
          onLoadMoreAppointments();
        }
        return false;
      },
      child: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.isLoading) const LinearProgressIndicator(),
                  AdminPatientProfilePanel(patient: patient),
                  SizedBox(height: 18.h),
                  AdminPatientAppointmentsSection(
                    state: state,
                    onRetry: onRetryAppointments,
                    onRetryMore: onLoadMoreAppointments,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminPatientErrorView extends StatelessWidget {
  const AdminPatientErrorView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.adminPatientDetailsError, textAlign: TextAlign.center),
            SizedBox(height: 12.h),
            OutlinedButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}
