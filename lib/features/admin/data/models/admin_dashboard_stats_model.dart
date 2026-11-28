import '../../domain/entities/admin_dashboard_stats.dart';

class AdminDashboardStatsModel extends AdminDashboardStats {
  const AdminDashboardStatsModel({
    required super.totalPatients,
    required super.totalDoctors,
    required super.pendingDoctors,
    required super.pendingApplications,
    required super.approvedDoctors,
    required super.totalSpecialties,
    required super.totalAppointments,
    required super.upcomingAppointments,
    required super.completedAppointments,
  });

  factory AdminDashboardStatsModel.fromCounts(List<int?> counts) {
    if (counts.length != AdminDashboardStats.metricCount) {
      throw ArgumentError.value(
        counts.length,
        'counts.length',
        'Expected ${AdminDashboardStats.metricCount} dashboard metrics.',
      );
    }

    return AdminDashboardStatsModel(
      totalPatients: counts[0],
      totalDoctors: counts[1],
      pendingDoctors: counts[2],
      pendingApplications: counts[3],
      approvedDoctors: counts[4],
      totalSpecialties: counts[5],
      totalAppointments: counts[6],
      upcomingAppointments: counts[7],
      completedAppointments: counts[8],
    );
  }
}
