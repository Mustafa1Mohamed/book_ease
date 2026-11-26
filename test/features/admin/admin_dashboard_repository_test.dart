import 'package:book_ease/features/admin/data/datasources/admin_dashboard_data_source.dart';
import 'package:book_ease/features/admin/data/models/admin_dashboard_stats_model.dart';
import 'package:book_ease/features/admin/data/repositories/admin_dashboard_repository_impl.dart';
import 'package:book_ease/features/admin/domain/errors/admin_dashboard_exception.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAdminDashboardDataSource implements AdminDashboardDataSource {
  _FakeAdminDashboardDataSource(this.stats);

  final AdminDashboardStatsModel stats;

  @override
  Future<AdminDashboardStatsModel> getDashboardStats() async => stats;
}

void main() {
  test('repository returns available metrics from its data source', () async {
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
    final repository = AdminDashboardRepositoryImpl(
      _FakeAdminDashboardDataSource(stats),
    );

    expect(await repository.getDashboardStats(), stats);
  });

  test('repository rejects a response with no available metrics', () async {
    final stats = AdminDashboardStatsModel.fromCounts(
      List<int?>.filled(8, null),
    );
    final repository = AdminDashboardRepositoryImpl(
      _FakeAdminDashboardDataSource(stats),
    );

    expect(
      repository.getDashboardStats(),
      throwsA(isA<AdminDashboardException>()),
    );
  });
}
