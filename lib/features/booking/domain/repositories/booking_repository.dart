import '../entities/appointment_slot.dart';
import '../entities/booking_confirmation.dart';

abstract interface class BookingRepository {
  Future<List<DateTime>> getAvailableDates(String doctorId);

  Future<List<AppointmentSlot>> getAvailableSlots(
    String doctorId,
    DateTime date,
  );

  Future<BookingConfirmation> bookAppointment({
    required String doctorId,
    required String slotId,
  });
}
