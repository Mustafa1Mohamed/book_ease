import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/errors/doctor_exception.dart';
import '../../domain/usecases/get_doctor_details.dart';
import 'doctor_details_state.dart';

class DoctorDetailsCubit extends Cubit<DoctorDetailsState> {
  DoctorDetailsCubit(this._getDoctorDetails)
    : super(const DoctorDetailsInitial());

  final GetDoctorDetails _getDoctorDetails;

  Future<void> load(String doctorId) async {
    final id = doctorId.trim();
    if (id.isEmpty) {
      emit(const DoctorDetailsNotFound());
      return;
    }

    emit(const DoctorDetailsLoading());
    try {
      final doctor = await _getDoctorDetails(id);
      emit(
        doctor == null
            ? const DoctorDetailsNotFound()
            : DoctorDetailsLoaded(doctor),
      );
    } on DoctorException catch (error) {
      emit(DoctorDetailsFailure(error.message));
    } on Exception catch (error, stackTrace) {
      debugPrint('Doctor details failed to load: $error\n$stackTrace');
      emit(
        const DoctorDetailsFailure(
          'Doctor details could not be loaded. Please try again.',
        ),
      );
    }
  }
}
