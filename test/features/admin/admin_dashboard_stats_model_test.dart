import 'package:book_ease/features/admin/data/models/admin_dashboard_stats_model.dart';
import 'package:book_ease/features/admin/domain/entities/admin_dashboard_stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps all aggregate counts to dashboard metrics', () {
    final stats = AdminDashboardStatsModel.fromCounts([
      10,
      8,
      3,
      4,
      6,
      20,
      7,
      9,
    ]);

    expect(stats.totalPatients, 10);
    expect(stats.totalDoctors, 8);
    expect(stats.pendingDoctors, 3);
    expect(stats.approvedDoctors, 4);
    expect(stats.totalSpecialties, 6);
    expect(stats.totalAppointments, 20);
    expect(stats.upcomingAppointments, 7);
    expect(stats.completedAppointments, 9);
    expect(stats.availableMetricCount, AdminDashboardStats.metricCount);
    expect(stats.hasUnavailableMetrics, isFalse);
  });

  test('preserves unavailable counts for partial metric display', () {
    final stats = AdminDashboardStatsModel.fromCounts([
      10,
      null,
      3,
      null,
      6,
      null,
      7,
      9,
    ]);

    expect(stats.totalDoctors, isNull);
    expect(stats.approvedDoctors, isNull);
    expect(stats.totalAppointments, isNull);
    expect(stats.availableMetricCount, 5);
    expect(stats.hasUnavailableMetrics, isTrue);
    expect(stats.hasAvailableMetrics, isTrue);
  });

  test('rejects a count list that does not match the dashboard metrics', () {
    expect(
      () => AdminDashboardStatsModel.fromCounts([1, 2]),
      throwsArgumentError,
    );
  });
}
