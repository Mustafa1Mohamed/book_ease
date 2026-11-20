import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/errors/my_appointments_exception.dart';
import '../../domain/services/appointment_cancellation_policy.dart';
import '../../domain/usecases/cancel_appointment.dart';
import '../../domain/usecases/get_my_appointment.dart';
import 'appointment_details_state.dart';

class AppointmentDetailsCubit extends Cubit<AppointmentDetailsState> {
  AppointmentDetailsCubit(
    this._getAppointment,
    this._cancelAppointment,
    this._cancellationPolicy,
  ) : super(const AppointmentDetailsInitial());

  final GetMyAppointment _getAppointment;
  final CancelAppointment _cancelAppointment;
  final AppointmentCancellationPolicy _cancellationPolicy;

  String get cancellationPolicyDescription =>
      _cancellationPolicy.policyDescription;

  bool canCancel(DateTime now) {
    final current = state;
    return current is AppointmentDetailsLoaded &&
        _cancellationPolicy.canCancel(current.appointment, now);
  }

  Future<void> load(String appointmentId) async {
    emit(const AppointmentDetailsLoading());
    try {
      final appointment = await _getAppointment(appointmentId);
      emit(
        appointment == null
            ? const AppointmentDetailsFailure(
                'This appointment could not be found.',
              )
            : AppointmentDetailsLoaded(appointment: appointment),
      );
    } on MyAppointmentsException catch (error) {
      emit(AppointmentDetailsFailure(error.message));
    } on Exception catch (error, stackTrace) {
      debugPrint('Appointment detail load failed: $error\n$stackTrace');
      emit(
        const AppointmentDetailsFailure(
          'Appointment details could not be loaded. Please retry.',
        ),
      );
    }
  }

  Future<void> cancel() async {
    final current = state;
    if (current is! AppointmentDetailsLoaded ||
        current.isCancelling ||
        !_cancellationPolicy.canCancel(
          current.appointment,
          DateTime.now(),
        )) {
      return;
    }

    emit(current.copyWith(isCancelling: true, clearError: true));
    try {
      await _cancelAppointment(current.appointment.id);
      final latest = state;
      if (latest is AppointmentDetailsLoaded) {
        emit(
          latest.copyWith(
            appointment: latest.appointment.copyWith(
              status: 'cancelled',
              cancelledAt: DateTime.now(),
            ),
            isCancelling: false,
            cancellationCompleted: true,
          ),
        );
      }
    } on MyAppointmentsException catch (error) {
      _emitCancellationFailure(error.message);
    } on Exception catch (error, stackTrace) {
      debugPrint('Appointment cancellation failed: $error\n$stackTrace');
      _emitCancellationFailure(
        'Appointment could not be cancelled. Please try again.',
      );
    }
  }

  void _emitCancellationFailure(String message) {
    final current = state;
    if (current is AppointmentDetailsLoaded) {
      emit(
        current.copyWith(
          isCancelling: false,
          errorMessage: message,
        ),
      );
    }
  }
}
