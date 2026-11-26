import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/errors/admin_dashboard_exception.dart';
import '../../domain/usecases/get_admin_dashboard_stats.dart';
import 'admin_dashboard_state.dart';

class AdminDashboardCubit extends Cubit<AdminDashboardState> {
  AdminDashboardCubit(this._getStats) : super(const AdminDashboardInitial());

  final GetAdminDashboardStats _getStats;

  Future<void> load() async {
    if (state is AdminDashboardLoading ||
        (state is AdminDashboardLoaded &&
            (state as AdminDashboardLoaded).isRefreshing)) {
      return;
    }

    final previous = state;
    if (previous case final AdminDashboardLoaded loaded) {
      emit(loaded.copyWith(isRefreshing: true, refreshFailed: false));
    } else {
      emit(const AdminDashboardLoading());
    }

    try {
      final stats = await _getStats();
      emit(AdminDashboardLoaded(stats));
    } on AdminDashboardException {
      if (previous case final AdminDashboardLoaded loaded) {
        emit(loaded.copyWith(isRefreshing: false, refreshFailed: true));
      } else {
        emit(const AdminDashboardFailure());
      }
    }
  }
}
