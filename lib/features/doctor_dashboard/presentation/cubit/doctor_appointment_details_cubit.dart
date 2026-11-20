import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/errors/doctor_dashboard_exception.dart';
import '../../domain/services/doctor_appointment_policy.dart';
import '../../domain/usecases/complete_doctor_appointment.dart';
import '../../domain/usecases/get_doctor_appointment.dart';
import 'doctor_appointment_details_state.dart';

class DoctorAppointmentDetailsCubit
    extends Cubit<DoctorAppointmentDetailsState> {
  DoctorAppointmentDetailsCubit(
    this._getAppointment,
    this._completeAppointment,
    this._appointmentPolicy,
  ) : super(const DoctorAppointmentDetailsInitial());

  final GetDoctorAppointment _getAppointment;
  final CompleteDoctorAppointment _completeAppointment;
  final DoctorAppointmentPolicy _appointmentPolicy;

  bool get canComplete {
    final current = state;
    return current is DoctorAppointmentDetailsLoaded &&
        _appointmentPolicy.canComplete(
          current.appointment,
          DateTime.now(),
        );
  }

  Future<void> load(String appointmentId) async {
    emit(const DoctorAppointmentDetailsLoading());
    try {
      final appointment = await _getAppointment(appointmentId);
      emit(
        appointment == null
            ? const DoctorAppointmentDetailsFailure(
                'This appointment could not be found.',
              )
            : DoctorAppointmentDetailsLoaded(appointment: appointment),
      );
    } on DoctorDashboardException catch (error) {
      emit(DoctorAppointmentDetailsFailure(error.message));
    } on Exception catch (error, stackTrace) {
      debugPrint('Doctor appointment details failed: $error\n$stackTrace');
      emit(
        const DoctorAppointmentDetailsFailure(
          'Appointment details could not be loaded. Please retry.',
        ),
      );
    }
  }

  Future<void> complete() async {
    final current = state;
    if (current is! DoctorAppointmentDetailsLoaded ||
        current.isUpdating ||
        !_appointmentPolicy.canComplete(
          current.appointment,
          DateTime.now(),
        )) {
      return;
    }

    emit(current.copyWith(isUpdating: true, clearError: true));
    try {
      await _completeAppointment(current.appointment.id);
      final latest = state;
      if (latest is DoctorAppointmentDetailsLoaded) {
        emit(
          latest.copyWith(
            appointment: latest.appointment.copyWith(status: 'completed'),
            isUpdating: false,
            completionCompleted: true,
          ),
        );
      }
    } on DoctorDashboardException catch (error) {
      _emitFailure(error.message);
    } on Exception catch (error, stackTrace) {
      debugPrint('Appointment completion failed: $error\n$stackTrace');
      _emitFailure('Appointment could not be completed. Please retry.');
    }
  }

  void _emitFailure(String message) {
    final current = state;
    if (current is DoctorAppointmentDetailsLoaded) {
      emit(current.copyWith(isUpdating: false, errorMessage: message));
    }
  }
}
