import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../cubit/my_appointments_cubit.dart';
import '../cubit/my_appointments_state.dart';
import '../widgets/my_appointments_content.dart';

class MyAppointmentsPage extends StatelessWidget {
  const MyAppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyAppointmentsCubit, MyAppointmentsState>(
      builder: (context, state) => switch (state) {
        MyAppointmentsInitial() || MyAppointmentsLoading() => const Center(
          child: CircularProgressIndicator(),
        ),
        MyAppointmentsFailure(:final message) => _InitialError(message: message),
        MyAppointmentsLoaded() => MyAppointmentsContent(state: state),
      },
    );
  }
}

class _InitialError extends StatelessWidget {
  const _InitialError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 44),
            SizedBox(height: 12.h),
            Text(message, textAlign: TextAlign.center),
            SizedBox(height: 12.h),
            FilledButton.icon(
              onPressed: context.read<MyAppointmentsCubit>().load,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
