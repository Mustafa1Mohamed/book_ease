import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../home/presentation/widgets/home_error_view.dart';
import '../cubit/doctor_appointment_details_cubit.dart';
import '../cubit/doctor_appointment_details_state.dart';
import '../widgets/doctor_appointment_details_content.dart';

class DoctorAppointmentDetailsPage extends StatelessWidget {
  const DoctorAppointmentDetailsPage({
    super.key,
    required this.appointmentId,
  });

  final String appointmentId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment details'),
        leading: IconButton(
          tooltip: 'Back to dashboard',
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: BlocConsumer<
        DoctorAppointmentDetailsCubit,
        DoctorAppointmentDetailsState
      >(
        listener: (context, state) {
          if (state is DoctorAppointmentDetailsLoaded &&
              state.completionCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Appointment marked completed.')),
            );
            context.pop(true);
          }
        },
        builder: (context, state) => switch (state) {
          DoctorAppointmentDetailsInitial() ||
          DoctorAppointmentDetailsLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          DoctorAppointmentDetailsFailure(:final message) => HomeErrorView(
            message: message,
            onRetry: () =>
                context.read<DoctorAppointmentDetailsCubit>().load(
                  appointmentId,
                ),
          ),
          DoctorAppointmentDetailsLoaded(
            :final appointment,
            :final isUpdating,
            :final errorMessage,
          ) =>
            DoctorAppointmentDetailsContent(
              appointment: appointment,
              canComplete: context
                  .read<DoctorAppointmentDetailsCubit>()
                  .canComplete,
              isUpdating: isUpdating,
              errorMessage: errorMessage,
              onComplete: context
                  .read<DoctorAppointmentDetailsCubit>()
                  .complete,
            ),
        },
      ),
    );
  }
}
