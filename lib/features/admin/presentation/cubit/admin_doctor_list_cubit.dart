import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/admin_doctor_filter.dart';
import '../../domain/errors/admin_doctor_exception.dart';
import '../../domain/repositories/admin_doctor_repository.dart';
import 'admin_doctor_list_state.dart';

class AdminDoctorListCubit extends Cubit<AdminDoctorListState> {
  AdminDoctorListCubit(this._repository) : super(const AdminDoctorListState());

  final AdminDoctorRepository _repository;
  int _request = 0;

  Future<void> load({AdminDoctorFilter? initialFilter}) async {
    if (initialFilter != null && initialFilter != state.filter) {
      emit(
        state.copyWith(
          filter: initialFilter,
          doctors: const [],
          clearCursor: true,
          hasMore: false,
          isLoadingMore: false,
        ),
      );
    }
    final request = ++_request;
    emit(state.copyWith(isLoading: state.doctors.isEmpty, hasError: false));
    await _loadSpecialties(request);
    try {
      final page = await _repository.getDoctors(
        filter: state.filter,
        search: state.search,
        specialtyId: state.specialtyId,
      );
      if (isClosed || request != _request) return;
      emit(
        state.copyWith(
          doctors: page.doctors,
          cursor: page.nextCursor,
          hasMore: page.hasMore,
          clearCursor: page.nextCursor == null,
          isLoading: false,
          hasError: false,
        ),
      );
    } on AdminDoctorException {
      if (!isClosed && request == _request) {
        emit(state.copyWith(isLoading: false, hasError: true));
      }
    }
  }

  Future<void> _loadSpecialties(int request) async {
    if (state.specialties.isNotEmpty) return;
    try {
      final specialties = await _repository.getSpecialties();
      if (!isClosed && request == _request) {
        emit(
          state.copyWith(
            specialties: specialties,
            specialtiesUnavailable: false,
          ),
        );
      }
    } on AdminDoctorException {
      if (!isClosed && request == _request) {
        emit(state.copyWith(specialtiesUnavailable: true));
      }
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore || state.cursor == null) return;
    final request = _request;
    emit(state.copyWith(isLoadingMore: true, hasError: false));
    try {
      final page = await _repository.getDoctors(
        filter: state.filter,
        search: state.search,
        specialtyId: state.specialtyId,
        cursor: state.cursor,
      );
      if (isClosed || request != _request) return;
      final seen = state.doctors.map((doctor) => doctor.id).toSet();
      emit(
        state.copyWith(
          doctors: [
            ...state.doctors,
            ...page.doctors.where((doctor) => seen.add(doctor.id)),
          ],
          cursor: page.nextCursor,
          hasMore: page.hasMore,
          clearCursor: page.nextCursor == null,
          isLoadingMore: false,
        ),
      );
    } on AdminDoctorException {
      if (!isClosed && request == _request) {
        emit(state.copyWith(isLoadingMore: false, hasError: true));
      }
    }
  }

  Future<void> updateSearch(String value) async {
    emit(state.copyWith(search: value, doctors: const [], clearCursor: true));
    await load();
  }

  Future<void> updateFilter(AdminDoctorFilter filter) async {
    emit(state.copyWith(filter: filter, doctors: const [], clearCursor: true));
    await load();
  }

  Future<void> updateSpecialty(String value) async {
    emit(
      state.copyWith(specialtyId: value, doctors: const [], clearCursor: true),
    );
    await load();
  }
}
