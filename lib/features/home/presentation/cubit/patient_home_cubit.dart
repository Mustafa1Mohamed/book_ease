import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/errors/patient_home_exception.dart';
import '../../domain/usecases/get_patient_home_data.dart';
import 'patient_home_state.dart';

class PatientHomeCubit extends Cubit<PatientHomeState> {
  PatientHomeCubit(this._getPatientHomeData)
    : super(const PatientHomeInitial());

  final GetPatientHomeData _getPatientHomeData;
  bool _isLoading = false;

  Future<void> load() async {
    if (_isLoading) return;
    _isLoading = true;
    final previous = state;
    if (previous is PatientHomeLoaded) {
      emit(PatientHomeLoaded(previous.data, isRefreshing: true));
    } else {
      emit(const PatientHomeLoading());
    }

    try {
      emit(PatientHomeLoaded(await _getPatientHomeData()));
    } on PatientHomeException catch (error) {
      _emitFailure(error.message, previous);
    } on Exception catch (error, stackTrace) {
      debugPrint('Patient home load failed: $error\n$stackTrace');
      _emitFailure(
        'Home data could not be loaded. Please try again.',
        previous,
      );
    } finally {
      _isLoading = false;
    }
  }

  void _emitFailure(String message, PatientHomeState previous) {
    if (previous is PatientHomeLoaded) {
      emit(PatientHomeLoaded(previous.data, refreshError: message));
    } else {
      emit(PatientHomeFailure(message));
    }
  }
}
