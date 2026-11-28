import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../domain/entities/doctor_application.dart';
import '../../domain/entities/doctor_application_page.dart';
import '../../domain/errors/doctor_application_exception.dart';
import '../../domain/repositories/doctor_application_repository.dart';
import '../datasources/doctor_application_remote_data_source.dart';

class DoctorApplicationRepositoryImpl implements DoctorApplicationRepository {
  const DoctorApplicationRepositoryImpl(this._remoteDataSource);

  final DoctorApplicationRemoteDataSource _remoteDataSource;

  @override
  Future<DoctorApplication?> getLatestForCurrentUser() =>
      _guard(_remoteDataSource.getLatestForCurrentUser);

  @override
  Future<List<DoctorApplication>> getApplicantHistory(String applicantUid) =>
      _guard(() => _remoteDataSource.getApplicantHistory(applicantUid));

  @override
  Future<List<DoctorApplicationSpecialty>> getSpecialties() =>
      _guard(_remoteDataSource.getSpecialties);

  @override
  Future<void> submit({
    required String fullName,
    required String phoneNumber,
    required String specialtyId,
    required String qualification,
    required int experienceYears,
    required String bio,
    required double consultationFee,
    required String clinicAddress,
  }) => _guard(
    () => _remoteDataSource.submit(
      fullName: fullName,
      phoneNumber: phoneNumber,
      specialtyId: specialtyId,
      qualification: qualification,
      experienceYears: experienceYears,
      bio: bio,
      consultationFee: consultationFee,
      clinicAddress: clinicAddress,
    ),
  );

  @override
  Future<DoctorApplicationPage> getApplications({
    required String status,
    required String specialtyId,
    required String search,
    String? cursor,
  }) => _guard(
    () => _remoteDataSource.getApplications(
      status: status,
      specialtyId: specialtyId,
      search: search,
      cursor: cursor,
    ),
  );

  @override
  Future<DoctorApplication?> getApplication(String applicationId) =>
      _guard(() => _remoteDataSource.getApplication(applicationId));

  @override
  Future<DoctorApplicantAccount?> getApplicantAccount(String applicantUid) =>
      _guard(() => _remoteDataSource.getApplicantAccount(applicantUid));

  @override
  Future<void> review({
    required String applicationId,
    required bool approve,
    String? reason,
  }) => _guard(
    () => _remoteDataSource.review(
      applicationId: applicationId,
      approve: approve,
      reason: reason,
    ),
  );

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DoctorApplicationException {
      rethrow;
    } on FirebaseFunctionsException catch (error) {
      throw DoctorApplicationException(_messageForCode(error.code));
    } on FirebaseException catch (error) {
      throw DoctorApplicationException(_messageForCode(error.code));
    }
  }

  String _messageForCode(String code) => switch (code) {
    'permission-denied' =>
      'You do not have permission to access this application.',
    'unauthenticated' => 'Sign in again to continue.',
    'already-exists' => 'An application is already under review.',
    'failed-precondition' =>
      'This application cannot be processed in its current state.',
    'invalid-argument' => 'Check the application details and try again.',
    'not-found' => 'The requested application was not found.',
    'unavailable' || 'deadline-exceeded' =>
      'The service is temporarily unavailable. Please retry.',
    _ => 'The application request could not be completed. Please retry.',
  };
}
