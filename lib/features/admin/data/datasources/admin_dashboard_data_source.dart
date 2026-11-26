import '../models/admin_dashboard_stats_model.dart';

abstract interface class AdminDashboardDataSource {
  Future<AdminDashboardStatsModel> getDashboardStats();
}
