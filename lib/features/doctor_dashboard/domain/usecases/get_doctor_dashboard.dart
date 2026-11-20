import '../entities/doctor_dashboard_data.dart';
import '../repositories/doctor_dashboard_repository.dart';

class GetDoctorDashboard {
  const GetDoctorDashboard(this._repository);

  final DoctorDashboardRepository _repository;

  Future<DoctorDashboardData> call() => _repository.getDashboard();
}
