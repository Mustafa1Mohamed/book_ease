import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../my_appointments/domain/entities/my_appointment.dart';
import '../../domain/errors/admin_patient_exception.dart';
import '../../domain/repositories/admin_patient_repository.dart';
import 'admin_patient_details_state.dart';

class AdminPatientDetailsCubit extends Cubit<AdminPatientDetailsState> {
  AdminPatientDetailsCubit(this._repository)
    : super(const AdminPatientDetailsState());

  final AdminPatientRepository _repository;
  int _request = 0;

  Future<void> load(String uid) async {
    final request = ++_request;
    emit(
      state.copyWith(
        clearPatient: true,
        appointments: const [],
        clearAppointmentCursor: true,
        appointmentsHasMore: false,
        isLoading: true,
        isAppointmentsLoading: false,
        isLoadingMoreAppointments: false,
        hasError: false,
        appointmentsHasError: false,
      ),
    );
    try {
      final patient = await _repository.getPatient(uid);
      if (isClosed || request != _request) return;
      emit(state.copyWith(patient: patient, isLoading: false));
      if (patient != null) await _loadAppointments(request, uid);
    } on AdminPatientException {
      if (!isClosed && request == _request) {
        emit(state.copyWith(isLoading: false, hasError: true));
      }
    }
  }

  Future<void> retryAppointments() async {
    final uid = state.patient?.uid;
    if (uid == null || state.isAppointmentsLoading) return;
    final request = ++_request;
    emit(
      state.copyWith(
        appointments: const [],
        clearAppointmentCursor: true,
        appointmentsHasMore: false,
        isAppointmentsLoading: true,
        appointmentsHasError: false,
      ),
    );
    await _loadAppointments(request, uid);
  }

  Future<void> _loadAppointments(int request, String uid) async {
    try {
      final page = await _repository.getAppointments(patientUid: uid);
      if (isClosed || request != _request) return;
      emit(
        state.copyWith(
          appointments: _uniqueAppointments(page.appointments),
          appointmentCursor: page.nextCursor,
          clearAppointmentCursor: page.nextCursor == null,
          appointmentsHasMore: page.hasMore && page.nextCursor != null,
          isAppointmentsLoading: false,
          appointmentsHasError: false,
        ),
      );
    } on AdminPatientException {
      if (!isClosed && request == _request) {
        emit(
          state.copyWith(
            isAppointmentsLoading: false,
            appointmentsHasError: true,
          ),
        );
      }
    }
  }

  Future<void> loadMoreAppointments() async {
    final patientUid = state.patient?.uid;
    final cursor = state.appointmentCursor;
    if (patientUid == null ||
        cursor == null ||
        !state.appointmentsHasMore ||
        state.isAppointmentsLoading ||
        state.isLoadingMoreAppointments) {
      return;
    }
    final request = _request;
    emit(
      state.copyWith(
        isLoadingMoreAppointments: true,
        appointmentsHasError: false,
      ),
    );
    try {
      final page = await _repository.getAppointments(
        patientUid: patientUid,
        cursor: cursor,
      );
      if (isClosed || request != _request) return;
      emit(
        state.copyWith(
          appointments: _uniqueAppointments([
            ...state.appointments,
            ...page.appointments,
          ]),
          appointmentCursor: page.nextCursor,
          clearAppointmentCursor: page.nextCursor == null,
          appointmentsHasMore: page.hasMore && page.nextCursor != null,
          isLoadingMoreAppointments: false,
          appointmentsHasError: false,
        ),
      );
    } on AdminPatientException {
      if (!isClosed && request == _request) {
        emit(
          state.copyWith(
            isLoadingMoreAppointments: false,
            appointmentsHasError: true,
          ),
        );
      }
    }
  }

  List<MyAppointment> _uniqueAppointments(List<MyAppointment> appointments) {
    final seen = <String>{};
    return appointments
        .where((appointment) {
          return seen.add(appointment.id);
        })
        .toList(growable: false);
  }
}
