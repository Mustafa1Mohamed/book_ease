import '../../../my_appointments/domain/entities/my_appointment.dart';
import '../../domain/entities/doctor_dashboard_data.dart';
import '../../domain/repositories/doctor_dashboard_repository.dart';
import '../datasources/doctor_dashboard_remote_data_source.dart';

class DoctorDashboardRepositoryImpl implements DoctorDashboardRepository {
  const DoctorDashboardRepositoryImpl(this._remoteDataSource);

  final DoctorDashboardRemoteDataSource _remoteDataSource;

  @override
  Future<DoctorDashboardData> getDashboard() {
    return _remoteDataSource.getDashboard();
  }

  @override
  Future<MyAppointment?> getAppointment(String appointmentId) {
    return _remoteDataSource.getAppointment(appointmentId);
  }

  @override
  Future<void> completeAppointment(String appointmentId) {
    return _remoteDataSource.completeAppointment(appointmentId);
  }
}
