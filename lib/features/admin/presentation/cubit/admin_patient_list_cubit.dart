import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/admin_patient.dart';
import '../../domain/errors/admin_patient_exception.dart';
import '../../domain/repositories/admin_patient_repository.dart';
import 'admin_patient_list_state.dart';

class AdminPatientListCubit extends Cubit<AdminPatientListState> {
  AdminPatientListCubit(this._repository)
    : super(const AdminPatientListState());

  final AdminPatientRepository _repository;
  int _request = 0;

  Future<void> load() async {
    if (state.isLoading || state.isRefreshing) return;
    final request = ++_request;
    final hasPatients = state.patients.isNotEmpty;
    emit(
      state.copyWith(
        isLoading: !hasPatients,
        isRefreshing: hasPatients,
        isLoadingMore: false,
        hasError: false,
        loadMoreHasError: false,
        hasMore: false,
        clearCursor: true,
      ),
    );
    await _loadFirstPage(request);
  }

  Future<void> updateSearch(String value) async {
    final search = value.trim();
    if (search == state.search) return;
    final request = ++_request;
    emit(
      state.copyWith(
        patients: const [],
        search: search,
        clearCursor: true,
        hasMore: false,
        isLoading: true,
        isRefreshing: false,
        isLoadingMore: false,
        hasError: false,
        loadMoreHasError: false,
      ),
    );
    await _loadFirstPage(request);
  }

  Future<void> _loadFirstPage(int request) async {
    try {
      final page = await _repository.getPatients(search: state.search);
      if (isClosed || request != _request) return;
      emit(
        state.copyWith(
          patients: _uniquePatients(page.patients),
          cursor: page.nextCursor,
          clearCursor: page.nextCursor == null,
          hasMore: page.hasMore && page.nextCursor != null,
          isLoading: false,
          isRefreshing: false,
          hasError: false,
          loadMoreHasError: false,
        ),
      );
    } on AdminPatientException {
      if (!isClosed && request == _request) {
        emit(
          state.copyWith(isLoading: false, isRefreshing: false, hasError: true),
        );
      }
    }
  }

  Future<void> loadMore() async {
    final cursor = state.cursor;
    if (!state.hasMore ||
        state.isLoading ||
        state.isLoadingMore ||
        cursor == null) {
      return;
    }
    final request = _request;
    emit(state.copyWith(isLoadingMore: true, loadMoreHasError: false));
    try {
      final page = await _repository.getPatients(
        search: state.search,
        cursor: cursor,
      );
      if (isClosed || request != _request) return;
      emit(
        state.copyWith(
          patients: _uniquePatients([...state.patients, ...page.patients]),
          cursor: page.nextCursor,
          clearCursor: page.nextCursor == null,
          hasMore: page.hasMore && page.nextCursor != null,
          isLoadingMore: false,
          loadMoreHasError: false,
        ),
      );
    } on AdminPatientException {
      if (!isClosed && request == _request) {
        emit(state.copyWith(isLoadingMore: false, loadMoreHasError: true));
      }
    }
  }

  List<AdminPatient> _uniquePatients(List<AdminPatient> patients) {
    final seen = <String>{};
    return patients
        .where((patient) => seen.add(patient.uid))
        .toList(growable: false);
  }
}
