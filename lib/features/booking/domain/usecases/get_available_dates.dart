import '../repositories/booking_repository.dart';

class GetAvailableDates {
  const GetAvailableDates(this._repository);

  final BookingRepository _repository;

  Future<List<DateTime>> call(String doctorId) {
    return _repository.getAvailableDates(doctorId);
  }
}
