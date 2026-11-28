import 'dart:async';

import 'package:book_ease/features/admin/domain/entities/admin_dashboard_stats.dart';
import 'package:book_ease/features/admin/domain/errors/admin_dashboard_exception.dart';
import 'package:book_ease/features/admin/domain/repositories/admin_dashboard_repository.dart';
import 'package:book_ease/features/admin/domain/usecases/get_admin_dashboard_stats.dart';
import 'package:book_ease/features/admin/presentation/cubit/admin_dashboard_cubit.dart';
import 'package:book_ease/features/admin/presentation/cubit/admin_dashboard_state.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAdminDashboardRepository implements AdminDashboardRepository {
  AdminDashboardStats stats = _stats;
  Object? error;
  Completer<AdminDashboardStats>? completer;

  @override
  Future<AdminDashboardStats> getDashboardStats() {
    if (error case final value?) return Future.error(value);
    if (completer case final value?) return value.future;
    return Future.value(stats);
  }
}

const _stats = AdminDashboardStats(
  totalPatients: 10,
  totalDoctors: 8,
  pendingDoctors: 3,
  pendingApplications: 12,
  approvedDoctors: 4,
  totalSpecialties: 6,
  totalAppointments: 20,
  upcomingAppointments: 7,
  completedAppointments: 9,
);

void main() {
  late _FakeAdminDashboardRepository repository;
  late AdminDashboardCubit cubit;

  setUp(() {
    repository = _FakeAdminDashboardRepository();
    cubit = AdminDashboardCubit(GetAdminDashboardStats(repository));
  });

  tearDown(() => cubit.close());

  test('emits loading then loaded dashboard statistics', () async {
    repository.completer = Completer<AdminDashboardStats>();
    final loading = cubit.load();

    expect(cubit.state, isA<AdminDashboardLoading>());

    repository.completer!.complete(_stats);
    await loading;

    expect(cubit.state, const AdminDashboardLoaded(_stats));
  });

  test('emits a failure when the initial load has no data', () async {
    repository.error = const AdminDashboardException();

    await cubit.load();

    expect(cubit.state, isA<AdminDashboardFailure>());
  });

  test('refresh replaces displayed metrics with the latest result', () async {
    await cubit.load();
    const updatedStats = AdminDashboardStats(
      totalPatients: 11,
      totalDoctors: 9,
      pendingDoctors: 2,
      pendingApplications: 11,
      approvedDoctors: 5,
      totalSpecialties: 7,
      totalAppointments: 21,
      upcomingAppointments: 8,
      completedAppointments: 10,
    );
    repository.stats = updatedStats;

    await cubit.load();

    expect(cubit.state, const AdminDashboardLoaded(updatedStats));
  });

  test(
    'refresh retains metrics while loading and after a refresh failure',
    () async {
      await cubit.load();
      repository.completer = Completer<AdminDashboardStats>();
      final refresh = cubit.load();

      expect(
        cubit.state,
        const AdminDashboardLoaded(_stats, isRefreshing: true),
      );

      repository.completer!.completeError(const AdminDashboardException());
      await refresh;

      expect(
        cubit.state,
        const AdminDashboardLoaded(_stats, refreshFailed: true),
      );
    },
  );
}
