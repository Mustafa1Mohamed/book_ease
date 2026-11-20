import '../repositories/doctor_dashboard_repository.dart';

class CompleteDoctorAppointment {
  const CompleteDoctorAppointment(this._repository);

  final DoctorDashboardRepository _repository;

  Future<void> call(String appointmentId) {
    return _repository.completeAppointment(appointmentId);
  }
}
