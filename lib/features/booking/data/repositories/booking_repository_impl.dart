import '../../domain/entities/appointment_slot.dart';
import '../../domain/entities/booking_confirmation.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_data_source.dart';

class BookingRepositoryImpl implements BookingRepository {
  const BookingRepositoryImpl(this._remoteDataSource);

  final BookingRemoteDataSource _remoteDataSource;

  @override
  Future<List<DateTime>> getAvailableDates(String doctorId) {
    return _remoteDataSource.getAvailableDates(doctorId);
  }

  @override
  Future<List<AppointmentSlot>> getAvailableSlots(
    String doctorId,
    DateTime date,
  ) {
    return _remoteDataSource.getAvailableSlots(doctorId, date);
  }

  @override
  Future<BookingConfirmation> bookAppointment({
    required String doctorId,
    required String slotId,
  }) {
    return _remoteDataSource.bookAppointment(
      doctorId: doctorId,
      slotId: slotId,
    );
  }
}
