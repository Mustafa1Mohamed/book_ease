import '../../domain/entities/my_appointment.dart';
import '../../domain/repositories/my_appointments_repository.dart';
import '../datasources/my_appointments_remote_data_source.dart';

class MyAppointmentsRepositoryImpl implements MyAppointmentsRepository {
  const MyAppointmentsRepositoryImpl(this._remoteDataSource);

  final MyAppointmentsRemoteDataSource _remoteDataSource;

  @override
  Future<List<MyAppointment>> getMyAppointments() {
    return _remoteDataSource.getMyAppointments();
  }

  @override
  Future<MyAppointment?> getMyAppointment(String appointmentId) {
    return _remoteDataSource.getMyAppointment(appointmentId);
  }

  @override
  Future<void> cancelAppointment(String appointmentId) {
    return _remoteDataSource.cancelAppointment(appointmentId);
  }
}
