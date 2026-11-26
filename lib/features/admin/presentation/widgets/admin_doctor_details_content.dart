import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../my_appointments/domain/entities/my_appointment.dart';
import '../../domain/entities/admin_doctor.dart';
import '../../domain/entities/admin_doctor_action.dart';
import '../cubit/admin_doctor_details_state.dart';
import 'admin_doctor_action_buttons.dart';
import 'admin_doctor_appointments_section.dart';
import 'admin_doctor_audit_section.dart';
import 'admin_doctor_profile_panel.dart';
import 'admin_doctor_review_warnings.dart';

class AdminDoctorDetailsContent extends StatelessWidget {
  const AdminDoctorDetailsContent({
    super.key,
    required this.doctor,
    required this.appointments,
    required this.appointmentsUnavailable,
    required this.state,
    required this.onAction,
    required this.onLoadMoreAudit,
    required this.onRetryAudit,
  });

  final AdminDoctor doctor;
  final List<MyAppointment> appointments;
  final bool appointmentsUnavailable;
  final AdminDoctorDetailsState state;
  final ValueChanged<AdminDoctorAction> onAction;
  final VoidCallback onLoadMoreAudit;
  final VoidCallback onRetryAudit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.isLoading) const LinearProgressIndicator(),
                AdminDoctorProfilePanel(doctor: doctor),
                AdminDoctorReviewWarnings(doctor: doctor),
                AdminDoctorActionButtons(
                  doctor: doctor,
                  isLoading: state.isActionLoading,
                  onAction: onAction,
                ),
                if (doctor.lifecycle.isSuspended)
                  _SuspendedNotice(
                    message: l10n.adminDoctorSuspendedAppointmentsWarning,
                  ),
                SizedBox(height: 24.h),
                AdminDoctorAppointmentsSection(
                  appointments: appointments,
                  unavailable: appointmentsUnavailable,
                ),
                SizedBox(height: 24.h),
                AdminDoctorAuditSection(
                  state: state,
                  retryAvailable: doctor.identityVerified,
                  onLoadMore: onLoadMoreAudit,
                  onRetry: onRetryAudit,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SuspendedNotice extends StatelessWidget {
  const _SuspendedNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: EdgeInsets.only(top: 12.h),
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Text(message),
  );
}
