import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/admin_specialty.dart';
import '../../domain/errors/admin_specialty_exception.dart';
import '../../domain/repositories/admin_specialty_repository.dart';
import 'admin_specialties_state.dart';

class AdminSpecialtiesCubit extends Cubit<AdminSpecialtiesState> {
  AdminSpecialtiesCubit(this._repository)
    : super(const AdminSpecialtiesState());

  final AdminSpecialtyRepository _repository;
  int _loadVersion = 0;

  Future<void> load() async {
    final version = ++_loadVersion;
    emit(
      state.copyWith(
        isLoading: state.specialties.isEmpty,
        clearLoadError: true,
      ),
    );
    try {
      final specialties = await _repository.getAll();
      if (isClosed || version != _loadVersion) return;
      emit(
        state.copyWith(
          specialties: specialties,
          isLoading: false,
          clearLoadError: true,
        ),
      );
    } on AdminSpecialtyException catch (error) {
      if (!isClosed && version == _loadVersion) {
        emit(state.copyWith(isLoading: false, loadError: error.code));
      }
    }
  }

  void updateQuery(String value) => emit(state.copyWith(query: value));

  void updateFilter(SpecialtyListFilter value) =>
      emit(state.copyWith(filter: value));

  Future<bool> save({
    String? specialtyId,
    required String name,
    required String nameAr,
    required String description,
    required String descriptionAr,
    required String iconName,
    required bool isActive,
    required bool clearImage,
  }) async {
    if (state.isSaving || state.isMutating) return false;
    emit(state.copyWith(isSaving: true, clearMutationError: true));
    try {
      final updated = await _repository.save(
        specialtyId: specialtyId,
        name: name,
        nameAr: nameAr,
        description: description,
        descriptionAr: descriptionAr,
        iconName: iconName,
        isActive: isActive,
        clearImage: clearImage,
      );
      if (isClosed) return false;
      final specialties =
          [
            for (final specialty in state.specialties)
              if (specialty.id != updated.id) specialty,
            updated,
          ]..sort(
            (first, second) =>
                first.name.toLowerCase().compareTo(second.name.toLowerCase()),
          );
      emit(
        state.copyWith(
          specialties: specialties,
          isSaving: false,
          clearMutationError: true,
        ),
      );
      return true;
    } on AdminSpecialtyException catch (error) {
      if (!isClosed) {
        emit(state.copyWith(isSaving: false, mutationError: error.code));
      }
      return false;
    }
  }

  Future<bool> setActive({
    required AdminSpecialty specialty,
    required bool isActive,
  }) async {
    if (state.isSaving || state.isMutating) return false;
    emit(state.copyWith(isMutating: true, clearMutationError: true));
    try {
      await _repository.setActive(
        specialtyId: specialty.id,
        isActive: isActive,
      );
      if (isClosed) return false;
      final updated = await _repository.getAll();
      if (isClosed) return false;
      emit(
        state.copyWith(
          specialties: updated,
          isMutating: false,
          clearMutationError: true,
        ),
      );
      return true;
    } on AdminSpecialtyException catch (error) {
      if (!isClosed) {
        emit(state.copyWith(isMutating: false, mutationError: error.code));
      }
      return false;
    }
  }

  Future<void> loadDoctorCount(String specialtyId) async {
    if (state.countSpecialtyId == specialtyId &&
        (state.doctorCount != null || state.isCountLoading)) {
      return;
    }
    emit(
      state.copyWith(
        isCountLoading: true,
        countSpecialtyId: specialtyId,
        clearDoctorCount: true,
        clearCountError: true,
      ),
    );
    try {
      final count = await _repository.getDoctorCount(specialtyId);
      if (!isClosed && state.countSpecialtyId == specialtyId) {
        emit(
          state.copyWith(
            isCountLoading: false,
            doctorCount: count,
            clearCountError: true,
          ),
        );
      }
    } on AdminSpecialtyException catch (error) {
      if (!isClosed && state.countSpecialtyId == specialtyId) {
        emit(state.copyWith(isCountLoading: false, countError: error.code));
      }
    }
  }

  AdminSpecialty? specialtyById(String id) {
    for (final specialty in state.specialties) {
      if (specialty.id == id) return specialty;
    }
    return null;
  }
}
