import '../../domain/entities/admin_dashboard_stats.dart';
import '../../domain/errors/admin_dashboard_exception.dart';
import '../../domain/repositories/admin_dashboard_repository.dart';
import '../datasources/admin_dashboard_data_source.dart';

class AdminDashboardRepositoryImpl implements AdminDashboardRepository {
  const AdminDashboardRepositoryImpl(this._dataSource);

  final AdminDashboardDataSource _dataSource;

  @override
  Future<AdminDashboardStats> getDashboardStats() async {
    final stats = await _dataSource.getDashboardStats();
    if (!stats.hasAvailableMetrics) throw const AdminDashboardException();
    return stats;
  }
}
