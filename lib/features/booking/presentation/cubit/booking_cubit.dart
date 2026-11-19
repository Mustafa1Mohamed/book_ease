import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../doctors/domain/errors/doctor_exception.dart';
import '../../../doctors/domain/usecases/get_doctor_details.dart';
import '../../domain/entities/appointment_slot.dart';
import '../../domain/errors/booking_exception.dart';
import '../../domain/usecases/book_appointment.dart';
import '../../domain/usecases/get_available_dates.dart';
import '../../domain/usecases/get_available_slots.dart';
import 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  BookingCubit(
    this._getDoctorDetails,
    this._getAvailableDates,
    this._getAvailableSlots,
    this._bookAppointment,
  ) : super(const BookingInitial());

  final GetDoctorDetails _getDoctorDetails;
  final GetAvailableDates _getAvailableDates;
  final GetAvailableSlots _getAvailableSlots;
  final BookAppointment _bookAppointment;
  int _slotRequestId = 0;

  Future<void> load(String doctorId) async {
    final requestId = ++_slotRequestId;
    emit(const BookingLoading());
    try {
      final doctor = await _getDoctorDetails(doctorId);
      if (doctor == null) {
        emit(const BookingFailure('This doctor is no longer available.'));
        return;
      }

      final dates = await _getAvailableDates(doctorId);
      if (requestId != _slotRequestId) return;
      final selectedDate = dates.isEmpty ? null : dates.first;
      emit(
        BookingReady(
          doctor: doctor,
          availableDates: dates,
          selectedDate: selectedDate,
          slots: const [],
          isLoadingSlots: selectedDate != null,
        ),
      );
      if (selectedDate != null) {
        await _loadSlots(doctorId, selectedDate, requestId);
      }
    } on DoctorException catch (error) {
      emit(BookingFailure(error.message));
    } on BookingException catch (error) {
      emit(BookingFailure(error.message));
    } on Exception catch (error, stackTrace) {
      debugPrint('Booking screen failed to load: $error\n$stackTrace');
      emit(
        const BookingFailure(
          'Appointment options could not be loaded. Please try again.',
        ),
      );
    }
  }

  Future<void> selectDate(DateTime date) async {
    final current = state;
    if (current is! BookingReady ||
        current.isSubmitting ||
        !current.availableDates.any((item) => _sameDay(item, date))) {
      return;
    }

    final requestId = ++_slotRequestId;
    final selectedDate = DateTime(date.year, date.month, date.day);
    emit(
      current.copyWith(
        selectedDate: selectedDate,
        clearSelectedSlot: true,
        slots: const [],
        isLoadingSlots: true,
        clearError: true,
      ),
    );
    await _loadSlots(current.doctor.id, selectedDate, requestId);
  }

  void selectSlot(AppointmentSlot slot) {
    final current = state;
    if (current is! BookingReady ||
        current.isSubmitting ||
        !current.slots.any((available) => available.id == slot.id)) {
      return;
    }
    emit(current.copyWith(selectedSlotId: slot.id, clearError: true));
  }

  Future<void> confirmBooking() async {
    final current = state;
    if (current is! BookingReady ||
        current.isSubmitting ||
        current.selectedSlotId == null) {
      return;
    }

    emit(current.copyWith(isSubmitting: true, clearError: true));
    try {
      final confirmation = await _bookAppointment(
        doctorId: current.doctor.id,
        slotId: current.selectedSlotId!,
      );
      final latest = state;
      if (latest is BookingReady) {
        emit(latest.copyWith(isSubmitting: false, confirmation: confirmation));
      }
    } on BookingException catch (error) {
      await _refreshAfterFailure(error.message);
    } on Exception catch (error, stackTrace) {
      debugPrint('Booking submission failed: $error\n$stackTrace');
      await _refreshAfterFailure(
        'Your appointment could not be booked. Please try again.',
      );
    }
  }

  Future<void> _loadSlots(
    String doctorId,
    DateTime date,
    int requestId,
  ) async {
    try {
      final slots = await _getAvailableSlots(doctorId, date);
      if (requestId != _slotRequestId || state is! BookingReady) return;
      final current = state as BookingReady;
      emit(
        current.copyWith(
          slots: slots,
          isLoadingSlots: false,
          clearSelectedSlot: true,
        ),
      );
    } on BookingException catch (error) {
      if (requestId != _slotRequestId || state is! BookingReady) return;
      emit(
        (state as BookingReady).copyWith(
          isLoadingSlots: false,
          errorMessage: error.message,
        ),
      );
    } on Exception catch (error, stackTrace) {
      if (requestId != _slotRequestId || state is! BookingReady) return;
      debugPrint('Appointment times failed to load: $error\n$stackTrace');
      emit(
        (state as BookingReady).copyWith(
          isLoadingSlots: false,
          errorMessage: 'Appointment times could not be loaded.',
        ),
      );
    }
  }

  Future<void> _refreshAfterFailure(String message) async {
    final current = state;
    if (current is! BookingReady) return;
    final selectedDate = current.selectedDate;
    var refreshedSlots = current.slots;
    if (selectedDate != null) {
      try {
        refreshedSlots = await _getAvailableSlots(
          current.doctor.id,
          selectedDate,
        );
      } on BookingException catch (error) {
        debugPrint('Could not refresh slots after booking failed: $error');
      } on Exception catch (error, stackTrace) {
        debugPrint(
          'Could not refresh slots after booking failed: $error\n$stackTrace',
        );
      }
    }
    final latest = state;
    if (latest is BookingReady) {
      emit(
        latest.copyWith(
          slots: refreshedSlots,
          isSubmitting: false,
          clearSelectedSlot: true,
          errorMessage: message,
        ),
      );
    }
  }

  bool _sameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}
