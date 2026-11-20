import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../home/presentation/widgets/home_error_view.dart';
import '../cubit/appointment_details_cubit.dart';
import '../cubit/appointment_details_state.dart';
import '../widgets/appointment_details_content.dart';

class AppointmentDetailsPage extends StatelessWidget {
  const AppointmentDetailsPage({super.key, required this.appointmentId});

  final String appointmentId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(8.w, 4.h, 16.w, 4.h),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Back to appointments',
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              Text(
                'Appointment details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocConsumer<
            AppointmentDetailsCubit,
            AppointmentDetailsState
          >(
            listener: (context, state) {
              if (state is AppointmentDetailsLoaded &&
                  state.cancellationCompleted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Appointment cancelled.')),
                );
                context.pop(true);
              }
            },
            builder: (context, state) => switch (state) {
              AppointmentDetailsInitial() ||
              AppointmentDetailsLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              AppointmentDetailsFailure(:final message) => HomeErrorView(
                message: message,
                onRetry: () => context
                    .read<AppointmentDetailsCubit>()
                    .load(appointmentId),
              ),
              AppointmentDetailsLoaded(
                :final appointment,
                :final isCancelling,
                :final errorMessage,
              ) =>
                AppointmentDetailsContent(
                  appointment: appointment,
                  isCancelling: isCancelling,
                  canCancel: context
                      .read<AppointmentDetailsCubit>()
                      .canCancel(DateTime.now()),
                  cancellationError: errorMessage,
                  policyDescription: context
                      .read<AppointmentDetailsCubit>()
                      .cancellationPolicyDescription,
                  onCancel: context.read<AppointmentDetailsCubit>().cancel,
                ),
            },
          ),
        ),
      ],
    );
  }
}
