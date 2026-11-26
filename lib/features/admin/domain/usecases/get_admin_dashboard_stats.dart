import '../entities/admin_dashboard_stats.dart';
import '../repositories/admin_dashboard_repository.dart';

class GetAdminDashboardStats {
  const GetAdminDashboardStats(this._repository);

  final AdminDashboardRepository _repository;

  Future<AdminDashboardStats> call() => _repository.getDashboardStats();
}
