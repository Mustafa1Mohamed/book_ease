import '../entities/booking_confirmation.dart';
import '../repositories/booking_repository.dart';

class BookAppointment {
  const BookAppointment(this._repository);

  final BookingRepository _repository;

  Future<BookingConfirmation> call({
    required String doctorId,
    required String slotId,
  }) {
    return _repository.bookAppointment(
      doctorId: doctorId,
      slotId: slotId,
    );
  }
}
