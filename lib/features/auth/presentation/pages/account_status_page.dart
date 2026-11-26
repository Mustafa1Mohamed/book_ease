import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:book_ease/core/localization/generated/app_localizations.dart';

import '../../domain/entities/doctor_lifecycle_status.dart';
import '../../domain/entities/user_role.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class AccountStatusPage extends StatelessWidget {
  const AccountStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthCubit>().state;
    final user = state is AuthAuthenticated ? state.user : null;
    final lifecycle = user?.role == UserRole.doctor
        ? user!.doctorLifecycleStatus
        : DoctorLifecycleStatus.unknown;
    final l10n = AppLocalizations.of(context);
    final (title, message) = lifecycle.isSuspended
        ? (l10n.doctorSuspendedTitle, l10n.doctorSuspendedMessage)
        : switch (lifecycle.accountApprovalStatus) {
            DoctorApprovalStatus.pending => (
              l10n.doctorApprovalPendingTitle,
              l10n.doctorApprovalPendingMessage,
            ),
            DoctorApprovalStatus.rejected => (
              l10n.doctorRejectedTitle,
              l10n.doctorRejectedMessage,
            ),
            DoctorApprovalStatus.profileMissing => (
              l10n.doctorProfileMissingTitle,
              l10n.doctorProfileMissingMessage,
            ),
            DoctorApprovalStatus.approved => (
              l10n.doctorAccessUnavailableTitle,
              l10n.doctorAccessUnavailableMessage,
            ),
            DoctorApprovalStatus.unknown => (
              l10n.doctorAccessUnavailableTitle,
              l10n.doctorAccessUnavailableMessage,
            ),
          };

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.accountStatusTitle),
        actions: [
          IconButton(
            tooltip: l10n.signOut,
            onPressed: context.read<AuthCubit>().signOut,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_user_outlined, size: 56),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
