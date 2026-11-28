import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/doctor_application_page.dart';
import '../../domain/errors/doctor_application_exception.dart';
import '../../domain/repositories/doctor_application_repository.dart';
import 'doctor_application_state.dart';

class DoctorApplicationCubit extends Cubit<DoctorApplicationState> {
  DoctorApplicationCubit(this._repository)
    : super(const DoctorApplicationState());

  final DoctorApplicationRepository _repository;
  StreamSubscription<List<DoctorApplicationSpecialty>>?
  _specialtiesSubscription;

  Future<void> loadStatus() async {
    emit(const DoctorApplicationState(isLoading: true));
    try {
      final application = await _repository.getLatestForCurrentUser();
      emit(DoctorApplicationState(application: application));
    } on DoctorApplicationException catch (error) {
      emit(DoctorApplicationState(errorMessage: error.message));
    }
  }

  Future<void> loadForm() async {
    await _specialtiesSubscription?.cancel();
    _specialtiesSubscription = null;
    emit(const DoctorApplicationState(isLoading: true, isForm: true));
    try {
      final application = await _repository.getLatestForCurrentUser();
      if (isClosed) return;
      final firstSnapshot = Completer<void>();
      _specialtiesSubscription = _repository.watchSpecialties().listen(
        (specialties) {
          if (isClosed) return;
          emit(
            DoctorApplicationState(
              isForm: true,
              application: application,
              specialties: specialties,
            ),
          );
          if (!firstSnapshot.isCompleted) firstSnapshot.complete();
        },
        onError: (Object error) {
          if (isClosed) return;
          emit(
            DoctorApplicationState(
              isForm: true,
              application: application,
              errorMessage: error is DoctorApplicationException
                  ? error.message
                  : 'Specialties could not be loaded. Please retry.',
            ),
          );
          if (!firstSnapshot.isCompleted) firstSnapshot.complete();
        },
      );
      await firstSnapshot.future;
    } on DoctorApplicationException catch (error) {
      emit(DoctorApplicationState(isForm: true, errorMessage: error.message));
    }
  }

  @override
  Future<void> close() async {
    await _specialtiesSubscription?.cancel();
    await super.close();
  }

  Future<void> submit({
    required String fullName,
    required String phoneNumber,
    required String specialtyId,
    required String qualification,
    required int experienceYears,
    required String bio,
    required double consultationFee,
    required String clinicAddress,
  }) async {
    final current = state;
    if (!current.isForm || current.isSubmitting || current.isLoading) return;
    emit(current.copyWith(isSubmitting: true, clearError: true));
    try {
      await _repository.submit(
        fullName: fullName,
        phoneNumber: phoneNumber,
        specialtyId: specialtyId,
        qualification: qualification,
        experienceYears: experienceYears,
        bio: bio,
        consultationFee: consultationFee,
        clinicAddress: clinicAddress,
      );
      emit(
        current.copyWith(
          isSubmitting: false,
          isSubmitted: true,
          clearError: true,
        ),
      );
    } on DoctorApplicationException catch (error) {
      emit(current.copyWith(isSubmitting: false, errorMessage: error.message));
    }
  }
}
