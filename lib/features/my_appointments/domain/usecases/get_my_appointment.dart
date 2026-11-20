import '../entities/my_appointment.dart';
import '../repositories/my_appointments_repository.dart';

class GetMyAppointment {
  const GetMyAppointment(this._repository);

  final MyAppointmentsRepository _repository;

  Future<MyAppointment?> call(String appointmentId) {
    return _repository.getMyAppointment(appointmentId);
  }
}
