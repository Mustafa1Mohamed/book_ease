import '../repositories/my_appointments_repository.dart';

class CancelAppointment {
  const CancelAppointment(this._repository);

  final MyAppointmentsRepository _repository;

  Future<void> call(String appointmentId) {
    return _repository.cancelAppointment(appointmentId);
  }
}
