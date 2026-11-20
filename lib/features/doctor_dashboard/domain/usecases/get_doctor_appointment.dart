import '../../../my_appointments/domain/entities/my_appointment.dart';
import '../repositories/doctor_dashboard_repository.dart';

class GetDoctorAppointment {
  const GetDoctorAppointment(this._repository);

  final DoctorDashboardRepository _repository;

  Future<MyAppointment?> call(String appointmentId) {
    return _repository.getAppointment(appointmentId);
  }
}
