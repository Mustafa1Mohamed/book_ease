import '../../../my_appointments/domain/entities/my_appointment.dart';
import '../entities/doctor_dashboard_data.dart';

abstract interface class DoctorDashboardRepository {
  Future<DoctorDashboardData> getDashboard();

  Future<MyAppointment?> getAppointment(String appointmentId);

  Future<void> completeAppointment(String appointmentId);
}
