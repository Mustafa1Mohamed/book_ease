import '../entities/appointment_slot.dart';
import '../repositories/booking_repository.dart';

class GetAvailableSlots {
  const GetAvailableSlots(this._repository);

  final BookingRepository _repository;

  Future<List<AppointmentSlot>> call(String doctorId, DateTime date) {
    return _repository.getAvailableSlots(doctorId, date);
  }
}
