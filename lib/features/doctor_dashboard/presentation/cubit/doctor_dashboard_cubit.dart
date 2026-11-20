import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/doctor_appointment_filter.dart';
import '../../domain/errors/doctor_dashboard_exception.dart';
import '../../domain/usecases/get_doctor_dashboard.dart';
import 'doctor_dashboard_state.dart';

class DoctorDashboardCubit extends Cubit<DoctorDashboardState> {
  DoctorDashboardCubit(this._getDashboard)
    : super(const DoctorDashboardInitial());

  final GetDoctorDashboard _getDashboard;
  bool _isLoading = false;

  Future<void> load() async {
    if (_isLoading) return;
    _isLoading = true;
    final previous = state;
    if (previous is DoctorDashboardLoaded) {
      emit(previous.copyWith(isRefreshing: true, clearRefreshError: true));
    } else {
      emit(const DoctorDashboardLoading());
    }

    try {
      final data = await _getDashboard();
      emit(
        DoctorDashboardLoaded(
          data: data,
          selectedDate: previous is DoctorDashboardLoaded
              ? previous.selectedDate
              : DateTime.now(),
          filter: previous is DoctorDashboardLoaded
              ? previous.filter
              : DoctorAppointmentFilter.all,
        ),
      );
    } on DoctorDashboardException catch (error) {
      _emitFailure(error.message, previous);
    } on Exception catch (error, stackTrace) {
      debugPrint('Doctor dashboard failed to load: $error\n$stackTrace');
      _emitFailure(
        'Dashboard data could not be loaded. Please try again.',
        previous,
      );
    } finally {
      _isLoading = false;
    }
  }

  Future<void> refresh() => load();

  void selectDate(DateTime date) {
    final current = state;
    if (current is DoctorDashboardLoaded) {
      emit(
        current.copyWith(
          selectedDate: DateTime(date.year, date.month, date.day),
        ),
      );
    }
  }

  void selectFilter(DoctorAppointmentFilter filter) {
    final current = state;
    if (current is DoctorDashboardLoaded && current.filter != filter) {
      emit(current.copyWith(filter: filter));
    }
  }

  void _emitFailure(String message, DoctorDashboardState previous) {
    if (previous is DoctorDashboardLoaded) {
      emit(previous.copyWith(isRefreshing: false, refreshError: message));
    } else {
      emit(DoctorDashboardFailure(message));
    }
  }
}
