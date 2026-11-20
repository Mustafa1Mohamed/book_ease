import '../entities/my_appointment.dart';
import '../repositories/my_appointments_repository.dart';

class GetMyAppointments {
  const GetMyAppointments(this._repository);

  final MyAppointmentsRepository _repository;

  Future<List<MyAppointment>> call() => _repository.getMyAppointments();
}
