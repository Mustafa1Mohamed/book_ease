import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/appointment_category.dart';
import '../../domain/entities/my_appointment.dart';
import '../../domain/errors/my_appointments_exception.dart';
import '../../domain/services/appointment_category_policy.dart';
import '../../domain/usecases/get_my_appointments.dart';
import 'my_appointments_state.dart';

class MyAppointmentsCubit extends Cubit<MyAppointmentsState> {
  MyAppointmentsCubit(this._getAppointments, this._categoryPolicy)
    : super(const MyAppointmentsInitial());

  final GetMyAppointments _getAppointments;
  final AppointmentCategoryPolicy _categoryPolicy;
  bool _isLoading = false;

  Future<void> load() async {
    if (_isLoading) return;
    _isLoading = true;
    final previous = state;
    if (previous is MyAppointmentsLoaded) {
      emit(previous.copyWith(isRefreshing: true, clearRefreshError: true));
    } else {
      emit(const MyAppointmentsLoading());
    }

    try {
      emit(
        MyAppointmentsLoaded(
          appointments: await _getAppointments(),
          selectedCategory: previous is MyAppointmentsLoaded
              ? previous.selectedCategory
              : AppointmentCategory.upcoming,
        ),
      );
    } on MyAppointmentsException catch (error) {
      _emitLoadFailure(error.message, previous);
    } on Exception catch (error, stackTrace) {
      debugPrint('Appointments load failed: $error\n$stackTrace');
      _emitLoadFailure(
        'Appointments could not be loaded. Please try again.',
        previous,
      );
    } finally {
      _isLoading = false;
    }
  }

  Future<void> refresh() => load();

  void selectCategory(AppointmentCategory category) {
    final current = state;
    if (current is MyAppointmentsLoaded && current.selectedCategory != category) {
      emit(current.copyWith(selectedCategory: category));
    }
  }

  List<MyAppointment> appointmentsFor(
    MyAppointmentsLoaded state,
    AppointmentCategory category, {
    DateTime? now,
  }) {
    return state.appointmentsFor(
      category,
      now ?? DateTime.now(),
      _categoryPolicy,
    );
  }

  void _emitLoadFailure(String message, MyAppointmentsState previous) {
    if (previous is MyAppointmentsLoaded) {
      emit(previous.copyWith(isRefreshing: false, refreshError: message));
    } else {
      emit(MyAppointmentsFailure(message));
    }
  }
}
