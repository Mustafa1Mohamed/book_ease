import 'package:equatable/equatable.dart';

import '../../domain/entities/admin_dashboard_stats.dart';

sealed class AdminDashboardState extends Equatable {
  const AdminDashboardState();

  @override
  List<Object?> get props => [];
}

class AdminDashboardInitial extends AdminDashboardState {
  const AdminDashboardInitial();
}

class AdminDashboardLoading extends AdminDashboardState {
  const AdminDashboardLoading();
}

class AdminDashboardFailure extends AdminDashboardState {
  const AdminDashboardFailure();
}

class AdminDashboardLoaded extends AdminDashboardState {
  const AdminDashboardLoaded(
    this.stats, {
    this.isRefreshing = false,
    this.refreshFailed = false,
  });

  final AdminDashboardStats stats;
  final bool isRefreshing;
  final bool refreshFailed;

  AdminDashboardLoaded copyWith({bool? isRefreshing, bool? refreshFailed}) =>
      AdminDashboardLoaded(
        stats,
        isRefreshing: isRefreshing ?? this.isRefreshing,
        refreshFailed: refreshFailed ?? this.refreshFailed,
      );

  @override
  List<Object?> get props => [stats, isRefreshing, refreshFailed];
}
