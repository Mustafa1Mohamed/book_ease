import '../entities/doctor_application.dart';
import '../entities/doctor_application_page.dart';

abstract interface class DoctorApplicationRepository {
  Future<DoctorApplication?> getLatestForCurrentUser();

  Future<List<DoctorApplication>> getApplicantHistory(String applicantUid);

  Future<List<DoctorApplicationSpecialty>> getSpecialties();

  Future<void> submit({
    required String fullName,
    required String phoneNumber,
    required String specialtyId,
    required String qualification,
    required int experienceYears,
    required String bio,
    required double consultationFee,
    required String clinicAddress,
  });

  Future<DoctorApplicationPage> getApplications({
    required String status,
    required String specialtyId,
    required String search,
    String? cursor,
  });

  Future<DoctorApplication?> getApplication(String applicationId);

  Future<DoctorApplicantAccount?> getApplicantAccount(String applicantUid);

  Future<void> review({
    required String applicationId,
    required bool approve,
    String? reason,
  });
}
