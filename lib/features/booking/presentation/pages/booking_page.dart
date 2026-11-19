import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_router.dart';
import '../../../home/presentation/widgets/home_avatar.dart';
import '../../../home/presentation/widgets/home_error_view.dart';
import '../../domain/entities/appointment_slot.dart';
import '../cubit/booking_cubit.dart';
import '../cubit/booking_state.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({super.key, required this.doctorId});

  final String doctorId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingCubit, BookingState>(
      builder: (context, state) => switch (state) {
        BookingInitial() || BookingLoading() => const Center(
          child: CircularProgressIndicator(),
        ),
        BookingFailure(:final message) => HomeErrorView(
          message: message,
          onRetry: () => context.read<BookingCubit>().load(doctorId),
        ),
        BookingReady(:final confirmation?) => _BookingSuccess(
          doctorName: confirmation.doctorName,
          startAt: confirmation.startAt,
          endAt: confirmation.endAt,
        ),
        BookingReady() => const _BookingForm(),
      },
    );
  }
}

class _BookingForm extends StatelessWidget {
  const _BookingForm();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BookingCubit>().state as BookingReady;
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      children: [
        Card(
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              children: [
                HomeAvatar(
                  imageUrl: state.doctor.imageUrl,
                  radius: 28,
                  fallbackIcon: Icons.medical_services_rounded,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.doctor.fullName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (state.doctor.specialtyName.isNotEmpty)
                        Text(state.doctor.specialtyName),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 18.h),
        Text('Choose a date', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 8.h),
        if (state.availableDates.isEmpty)
          const _NoAvailabilityMessage()
        else
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              for (final date in state.availableDates)
                ChoiceChip(
                  label: Text(
                    '${DateFormat.E().format(date)}\n${DateFormat.MMMd().format(date)}',
                    textAlign: TextAlign.center,
                  ),
                  selected: _sameDay(state.selectedDate, date),
                  onSelected: state.isSubmitting
                      ? null
                      : (_) => context.read<BookingCubit>().selectDate(date),
                ),
            ],
          ),
        SizedBox(height: 20.h),
        Text(
          'Available times',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 8.h),
        if (state.isLoadingSlots)
          const Center(child: CircularProgressIndicator())
        else if (state.selectedDate == null || state.slots.isEmpty)
          const Text('No appointment times are available for this date.')
        else
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              for (final slot in state.slots)
                ChoiceChip(
                  label: Text(_slotLabel(slot)),
                  selected: state.selectedSlotId == slot.id,
                  onSelected: state.isSubmitting
                      ? null
                      : (_) => context.read<BookingCubit>().selectSlot(slot),
                ),
            ],
          ),
        if (state.errorMessage case final message?) ...[
          SizedBox(height: 12.h),
          Text(
            message,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        SizedBox(height: 20.h),
        if (state.doctor.consultationFee != null)
          Text(
            'Consultation fee: ${_formatFee(state.doctor.consultationFee!)}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        SizedBox(height: 12.h),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: state.selectedSlotId == null ||
                    state.isSubmitting ||
                    state.isLoadingSlots
                ? null
                : context.read<BookingCubit>().confirmBooking,
            icon: state.isSubmitting
                ? SizedBox(
                    width: 18.w,
                    height: 18.w,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded),
            label: Text(state.isSubmitting ? 'Booking...' : 'Confirm booking'),
          ),
        ),
      ],
    );
  }

  static bool _sameDay(DateTime? first, DateTime second) =>
      first != null &&
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;

  static String _slotLabel(AppointmentSlot slot) {
    final start = DateFormat.jm().format(slot.startAt.toLocal());
    final end = DateFormat.jm().format(slot.endAt.toLocal());
    return '$start – $end';
  }

  static String _formatFee(double fee) =>
      fee == fee.roundToDouble() ? fee.toStringAsFixed(0) : fee.toString();
}

class _NoAvailabilityMessage extends StatelessWidget {
  const _NoAvailabilityMessage();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'There are no upcoming appointment dates published for this doctor yet.',
    );
  }
}

class _BookingSuccess extends StatelessWidget {
  const _BookingSuccess({
    required this.doctorName,
    required this.startAt,
    required this.endAt,
  });

  final String doctorName;
  final DateTime startAt;
  final DateTime endAt;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 64.w,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 16.h),
            Text(
              'Appointment confirmed',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'Your appointment with $doctorName is scheduled for '
              '${DateFormat.yMMMd().add_jm().format(startAt.toLocal())} '
              '(${DateFormat.jm().format(endAt.toLocal())} end).',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            FilledButton.icon(
              onPressed: () => context.goNamed(AppRouter.appointments),
              icon: const Icon(Icons.calendar_month_rounded),
              label: const Text('My appointments'),
            ),
          ],
        ),
      ),
    );
  }
}
