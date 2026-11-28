import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/doctor_application.dart';
import '../../domain/errors/doctor_application_exception.dart';
import '../../domain/repositories/doctor_application_repository.dart';
import 'admin_doctor_applications_state.dart';

class AdminDoctorApplicationsCubit extends Cubit<AdminDoctorApplicationsState> {
  AdminDoctorApplicationsCubit(this._repository)
    : super(const AdminDoctorApplicationsState());

  final DoctorApplicationRepository _repository;
  int _request = 0;

  Future<void> load() async {
    final request = ++_request;
    emit(
      state.copyWith(
        isLoading: state.applications.isEmpty,
        isLoadingMore: false,
        hasError: false,
        clearError: true,
      ),
    );
    try {
      final specialties = state.specialties.isEmpty
          ? await _repository.getSpecialties()
          : state.specialties;
      if (isClosed || request != _request) return;
      emit(state.copyWith(specialties: specialties));
      final page = await _repository.getApplications(
        status: state.status,
        specialtyId: state.specialtyId,
        search: state.search,
      );
      if (isClosed || request != _request) return;
      emit(
        state.copyWith(
          applications: page.applications,
          cursor: page.nextCursor,
          clearCursor: page.nextCursor == null,
          hasMore: page.hasMore,
          isLoading: false,
          hasError: false,
        ),
      );
    } on DoctorApplicationException catch (error) {
      if (!isClosed && request == _request) {
        emit(
          state.copyWith(
            isLoading: false,
            hasError: true,
            errorMessage: error.message,
          ),
        );
      }
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore || state.cursor == null) return;
    final request = _request;
    emit(state.copyWith(isLoadingMore: true, hasError: false));
    try {
      final page = await _repository.getApplications(
        status: state.status,
        specialtyId: state.specialtyId,
        search: state.search,
        cursor: state.cursor,
      );
      if (isClosed || request != _request) return;
      final seen = state.applications
          .map((application) => application.id)
          .toSet();
      emit(
        state.copyWith(
          applications: [
            ...state.applications,
            ...page.applications.where(
              (application) => seen.add(application.id),
            ),
          ],
          cursor: page.nextCursor,
          clearCursor: page.nextCursor == null,
          hasMore: page.hasMore,
          isLoadingMore: false,
          hasError: false,
        ),
      );
    } on DoctorApplicationException catch (error) {
      if (!isClosed && request == _request) {
        emit(
          state.copyWith(
            isLoadingMore: false,
            hasError: true,
            errorMessage: error.message,
          ),
        );
      }
    }
  }

  Future<void> updateSearch(String value) async {
    emit(
      state.copyWith(
        search: value.trim(),
        applications: const [],
        clearCursor: true,
        hasMore: false,
      ),
    );
    await load();
  }

  Future<void> updateStatus(String value) async {
    emit(
      state.copyWith(
        status: value,
        applications: const [],
        clearCursor: true,
        hasMore: false,
      ),
    );
    await load();
  }

  Future<void> updateSpecialty(String value) async {
    emit(
      state.copyWith(
        specialtyId: value,
        applications: const [],
        clearCursor: true,
        hasMore: false,
      ),
    );
    await load();
  }

  Future<void> reloadAfterReview() => load();
}

class AdminDoctorApplicationDetailsState extends Equatable {
  const AdminDoctorApplicationDetailsState({
    this.application,
    this.applicantAccount,
    this.history = const [],
    this.isLoading = true,
    this.isReviewing = false,
    this.errorMessage,
    this.reviewError,
  });

  final DoctorApplication? application;
  final DoctorApplicantAccount? applicantAccount;
  final List<DoctorApplication> history;
  final bool isLoading;
  final bool isReviewing;
  final String? errorMessage;
  final String? reviewError;

  @override
  List<Object?> get props => [
    application,
    applicantAccount,
    history,
    isLoading,
    isReviewing,
    errorMessage,
    reviewError,
  ];
}

class AdminDoctorApplicationDetailsCubit
    extends Cubit<AdminDoctorApplicationDetailsState> {
  AdminDoctorApplicationDetailsCubit(this._repository)
    : super(const AdminDoctorApplicationDetailsState());

  final DoctorApplicationRepository _repository;

  Future<void> load(String applicationId) async {
    emit(const AdminDoctorApplicationDetailsState(isLoading: true));
    try {
      final application = await _repository.getApplication(applicationId);
      if (application == null) {
        emit(
          const AdminDoctorApplicationDetailsState(
            isLoading: false,
            errorMessage: 'Application was not found.',
          ),
        );
        return;
      }
      final history = await _repository.getApplicantHistory(
        application.applicantUid,
      );
      final applicantAccount = await _repository.getApplicantAccount(
        application.applicantUid,
      );
      emit(
        AdminDoctorApplicationDetailsState(
          application: application,
          applicantAccount: applicantAccount,
          history: history,
          isLoading: false,
        ),
      );
    } on DoctorApplicationException catch (error) {
      emit(
        AdminDoctorApplicationDetailsState(
          isLoading: false,
          errorMessage: error.message,
        ),
      );
    }
  }

  Future<void> review({required bool approve, String? reason}) async {
    final application = state.application;
    if (application == null ||
        application.status != DoctorApplicationStatus.pending ||
        state.isReviewing) {
      return;
    }
    emit(
      AdminDoctorApplicationDetailsState(
        application: application,
        applicantAccount: state.applicantAccount,
        history: state.history,
        isLoading: false,
        isReviewing: true,
      ),
    );
    try {
      await _repository.review(
        applicationId: application.id,
        approve: approve,
        reason: reason,
      );
      await load(application.id);
    } on DoctorApplicationException catch (error) {
      emit(
        AdminDoctorApplicationDetailsState(
          application: application,
          history: state.history,
          isLoading: false,
          reviewError: error.message,
        ),
      );
    }
  }
}
