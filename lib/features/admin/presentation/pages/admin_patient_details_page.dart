import 'dart:ui' as ui show TextDirection;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../cubit/admin_patient_details_cubit.dart';
import '../cubit/admin_patient_details_state.dart';
import '../widgets/admin_patient_details_content.dart';

class AdminPatientDetailsPage extends StatelessWidget {
  const AdminPatientDetailsPage({super.key, required this.patientId});

  final String patientId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final direction = l10n.localeName.startsWith('ar')
        ? ui.TextDirection.rtl
        : ui.TextDirection.ltr;
    return Directionality(
      textDirection: direction,
      child: BlocBuilder<AdminPatientDetailsCubit, AdminPatientDetailsState>(
        builder: (context, state) {
          final cubit = context.read<AdminPatientDetailsCubit>();
          return Scaffold(
            appBar: AppBar(title: Text(l10n.adminPatientDetailsTitle)),
            body: switch (state) {
              _ when state.patient != null => AdminPatientDetailsContent(
                patient: state.patient!,
                state: state,
                onRetryAppointments: cubit.retryAppointments,
                onLoadMoreAppointments: cubit.loadMoreAppointments,
              ),
              _ when state.isLoading => const Center(
                child: CircularProgressIndicator(),
              ),
              _ when state.hasError => AdminPatientErrorView(
                onRetry: () => cubit.load(patientId),
              ),
              _ => Center(child: Text(l10n.adminPatientNotFound)),
            },
          );
        },
      ),
    );
  }
}
