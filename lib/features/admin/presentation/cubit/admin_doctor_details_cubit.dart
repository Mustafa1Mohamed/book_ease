import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/admin_doctor_action.dart';
import '../../domain/errors/admin_doctor_exception.dart';
import '../../domain/repositories/admin_doctor_repository.dart';
import 'admin_doctor_details_state.dart';

class AdminDoctorDetailsCubit extends Cubit<AdminDoctorDetailsState> {
  AdminDoctorDetailsCubit(this._repository)
    : super(const AdminDoctorDetailsState());

  final AdminDoctorRepository _repository;
  final _operationIds = <String, String>{};
  final _random = Random.secure();
  String _doctorId = '';

  Future<void> load(String doctorId) async {
    _doctorId = doctorId;
    emit(
      state.copyWith(
        isLoading: true,
        hasError: false,
        auditHasError: false,
        auditEvents: const [],
        clearAuditCursor: true,
        auditHasMore: false,
        actionSucceeded: false,
        actionFailed: false,
      ),
    );
    try {
      final details = await _repository.getDoctorDetails(doctorId);
      if (isClosed) return;
      emit(state.copyWith(details: details, isLoading: false, hasError: false));
      await _loadAudit(reset: true);
    } on AdminDoctorException {
      if (!isClosed) emit(state.copyWith(isLoading: false, hasError: true));
    }
  }

  Future<void> loadMoreAudit() => _loadAudit(reset: false);
  Future<void> retryAudit() => _loadAudit(reset: true);

  Future<void> _loadAudit({required bool reset}) async {
    final doctor = state.details?.doctor;
    if (doctor == null || state.isAuditLoading) return;
    if (!doctor.identityVerified || doctor.uid.isEmpty) {
      emit(state.copyWith(auditHasError: true));
      return;
    }
    if (!reset && (!state.auditHasMore || state.auditCursor == null)) {
      return;
    }
    emit(state.copyWith(isAuditLoading: true, auditHasError: false));
    try {
      final page = await _repository.getAuditHistory(
        targetDoctorUid: doctor.uid,
        cursor: reset ? null : state.auditCursor,
      );
      if (isClosed || _doctorId.isEmpty) return;
      emit(
        state.copyWith(
          auditEvents: reset
              ? page.events
              : [...state.auditEvents, ...page.events],
          auditCursor: page.nextCursor,
          clearAuditCursor: page.nextCursor == null,
          auditHasMore: page.hasMore,
          isAuditLoading: false,
          auditHasError: false,
        ),
      );
    } on AdminDoctorException {
      if (!isClosed) {
        emit(state.copyWith(isAuditLoading: false, auditHasError: true));
      }
    }
  }

  Future<void> performAction({
    required AdminDoctorAction action,
    required String reason,
  }) async {
    final doctor = state.details?.doctor;
    if (doctor == null ||
        !doctor.canAdminister ||
        state.isActionLoading ||
        (AdminDoctorActionPolicy.reasonRequired(action) &&
            (reason.trim().isEmpty || reason.trim().length > 500)) ||
        reason.length > 500 ||
        !AdminDoctorActionPolicy.actionsFor(doctor).contains(action)) {
      return;
    }
    final normalizedReason = reason.trim();
    final key = '${doctor.uid}:${action.name}:$normalizedReason';
    final operationId = _operationIds.putIfAbsent(key, _newOperationId);
    emit(
      state.copyWith(
        isActionLoading: true,
        actionSucceeded: false,
        actionFailed: false,
      ),
    );
    try {
      await _repository.performAction(
        actionName: action.name,
        targetDoctorUid: doctor.uid,
        operationId: operationId,
        reason: normalizedReason.isEmpty ? null : normalizedReason,
      );
      _operationIds.remove(key);
      if (isClosed) return;
      emit(
        state.copyWith(
          isActionLoading: false,
          actionSucceeded: true,
          actionFailed: false,
        ),
      );
      await load(_doctorId);
    } on AdminDoctorException {
      if (!isClosed) {
        emit(
          state.copyWith(
            isActionLoading: false,
            actionSucceeded: false,
            actionFailed: true,
          ),
        );
      }
    }
  }

  String _newOperationId() =>
      List.generate(32, (_) => _random.nextInt(16).toRadixString(16)).join();
}
