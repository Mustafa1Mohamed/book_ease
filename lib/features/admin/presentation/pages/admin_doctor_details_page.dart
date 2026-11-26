import 'dart:ui' as ui show TextDirection;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../domain/entities/admin_doctor_action.dart';
import '../cubit/admin_doctor_details_cubit.dart';
import '../cubit/admin_doctor_details_state.dart';
import '../widgets/admin_doctor_action_confirmation.dart';
import '../widgets/admin_doctor_details_content.dart';

class AdminDoctorDetailsPage extends StatelessWidget {
  const AdminDoctorDetailsPage({super.key, required this.doctorId});

  final String doctorId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final direction = l10n.localeName.startsWith('ar')
        ? ui.TextDirection.rtl
        : ui.TextDirection.ltr;
    return Directionality(
      textDirection: direction,
      child: BlocConsumer<AdminDoctorDetailsCubit, AdminDoctorDetailsState>(
        listener: (context, state) {
          final message = state.actionSucceeded
              ? l10n.adminDoctorActionSuccess
              : state.actionFailed
              ? l10n.adminDoctorActionError
              : null;
          if (message != null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(message)));
          }
        },
        builder: (context, state) {
          final cubit = context.read<AdminDoctorDetailsCubit>();
          return Scaffold(
            appBar: AppBar(title: Text(l10n.adminDoctorDetailsTitle)),
            body: switch (state) {
              _ when state.details != null => AdminDoctorDetailsContent(
                doctor: state.details!.doctor,
                appointments: state.details!.upcomingAppointments,
                appointmentsUnavailable:
                    state.details!.upcomingAppointmentsUnavailable,
                state: state,
                onAction: (action) => _performAction(context, cubit, action),
                onLoadMoreAudit: cubit.loadMoreAudit,
                onRetryAudit: cubit.retryAudit,
              ),
              _ when state.isLoading => const Center(
                child: CircularProgressIndicator(),
              ),
              _ when state.hasError => _ErrorView(
                message: l10n.adminDoctorDetailsError,
                onRetry: () => cubit.load(doctorId),
              ),
              _ => const SizedBox.shrink(),
            },
          );
        },
      ),
    );
  }

  Future<void> _performAction(
    BuildContext context,
    AdminDoctorDetailsCubit cubit,
    AdminDoctorAction action,
  ) async {
    final reason = await showAdminDoctorActionConfirmation(context, action);
    if (reason != null && context.mounted) {
      await cubit.performAction(action: action, reason: reason);
    }
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onRetry,
            child: Text(AppLocalizations.of(context).retry),
          ),
        ],
      ),
    ),
  );
}
