// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'BookEase';

  @override
  String get welcome => 'Welcome to BookEase';

  @override
  String get welcomeSubtitle => 'Book your healthcare appointments with ease.';

  @override
  String get home => 'Home';

  @override
  String get appointments => 'Appointments';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get continueText => 'Continue';

  @override
  String get login => 'Login';

  @override
  String get register => 'Create Account';

  @override
  String get email => 'Email Address';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get searchDoctors => 'Search doctors or specialties';

  @override
  String get specialties => 'Specialties';

  @override
  String get featuredDoctors => 'Featured Doctors';

  @override
  String get seeAll => 'See All';

  @override
  String get adminDashboardTitle => 'Admin dashboard';

  @override
  String get adminDashboardOverview => 'Platform overview';

  @override
  String get adminDashboardSubtitle =>
      'A live snapshot of activity across BookEase.';

  @override
  String get adminTotalPatients => 'Total patients';

  @override
  String get adminTotalDoctors => 'Total doctors';

  @override
  String get adminPendingDoctors => 'Pending doctors';

  @override
  String get adminApprovedDoctors => 'Approved doctors';

  @override
  String get adminTotalSpecialties => 'Total specialties';

  @override
  String get adminTotalAppointments => 'Total appointments';

  @override
  String get adminUpcomingAppointments => 'Upcoming appointments';

  @override
  String get adminCompletedAppointments => 'Completed appointments';

  @override
  String get adminMetricUnavailable => 'Unavailable';

  @override
  String get adminDashboardUnavailable => 'Dashboard unavailable';

  @override
  String get adminDashboardLoadError =>
      'Dashboard statistics could not be loaded. Check your connection and admin access, then try again.';

  @override
  String get adminDashboardRefreshError =>
      'The latest statistics could not be refreshed. Showing the last available data.';

  @override
  String get adminDashboardPartialError =>
      'Some statistics are unavailable. Check your access and try again.';

  @override
  String get adminDoctorsTitle => 'Doctor management';

  @override
  String get adminDoctorsSubtitle =>
      'Review doctor profiles and manage their access.';

  @override
  String get adminDoctorsSearch => 'Search name or email';

  @override
  String get adminDoctorsAll => 'All';

  @override
  String get adminDoctorsPending => 'Pending';

  @override
  String get adminDoctorsApproved => 'Approved';

  @override
  String get adminDoctorsRejected => 'Rejected';

  @override
  String get adminDoctorsSuspended => 'Suspended';

  @override
  String get adminDoctorsSpecialty => 'Specialty';

  @override
  String get adminDoctorsAllSpecialties => 'All specialties';

  @override
  String get adminDoctorsNeedsReview => 'Needs review';

  @override
  String get adminDoctorsLegacyNotice =>
      'All includes legacy or malformed profiles. Status filters require a stored approval status; approved includes legacy active defaults. Search by email to find doctor users without a linked profile.';

  @override
  String get adminDoctorsEmpty => 'No doctors match these filters.';

  @override
  String get adminDoctorsLoadError =>
      'Doctors could not be loaded. Check access and connection, then retry.';

  @override
  String get adminDoctorsSpecialtiesUnavailable =>
      'Specialty filtering is unavailable.';

  @override
  String get adminDoctorsLoadMore => 'Load more';

  @override
  String get adminDoctorDetailsTitle => 'Doctor details';

  @override
  String get adminDoctorProfile => 'Profile information';

  @override
  String get adminDoctorIdentity => 'Identity';

  @override
  String get adminDoctorProfileId => 'Profile ID';

  @override
  String get adminDoctorUid => 'User UID';

  @override
  String get adminDoctorEmail => 'Email';

  @override
  String get adminDoctorPhone => 'Phone';

  @override
  String get adminDoctorSpecialty => 'Specialty';

  @override
  String get adminDoctorFee => 'Consultation fee';

  @override
  String get adminDoctorBiography => 'Biography';

  @override
  String get adminDoctorQualifications => 'Qualifications';

  @override
  String get adminDoctorExperience => 'Years of experience';

  @override
  String get adminDoctorClinic => 'Clinic';

  @override
  String get adminDoctorAddress => 'Clinic address';

  @override
  String get adminDoctorApprovalStatus => 'Approval status';

  @override
  String get adminDoctorAdministrativeStatus => 'Administrative status';

  @override
  String get adminDoctorActive => 'Active';

  @override
  String get adminDoctorNeedsReviewMessage =>
      'This record needs manual review. Lifecycle actions are disabled until its identity and status are valid.';

  @override
  String get adminDoctorMissingUser => 'Linked user record is missing.';

  @override
  String get adminDoctorMissingProfile =>
      'No doctor profile is linked to this doctor user.';

  @override
  String get adminDoctorRoleMismatch =>
      'Linked user is not registered with the doctor role.';

  @override
  String get adminDoctorIdentityMissing =>
      'A unique doctor identity could not be resolved.';

  @override
  String get adminDoctorIdentityLegacy => 'Legacy profile link is in use.';

  @override
  String get adminDoctorIdentityMismatch =>
      'Doctor profile and user links conflict.';

  @override
  String get adminDoctorIdentityAmbiguous =>
      'Multiple doctor profiles are linked to this user.';

  @override
  String get adminDoctorStatusMissing =>
      'A lifecycle status is missing; the compatibility default is shown.';

  @override
  String get adminDoctorInvalidStatus =>
      'Lifecycle status is invalid or internally inconsistent.';

  @override
  String get adminDoctorIncompleteProfile =>
      'Some profile information is missing.';

  @override
  String get adminDoctorAppointments => 'Upcoming appointments';

  @override
  String get adminDoctorNoAppointments =>
      'No upcoming appointments were found.';

  @override
  String get adminDoctorAppointmentsUnavailable =>
      'Upcoming appointments could not be loaded.';

  @override
  String get adminAppointmentStatusConfirmed => 'Confirmed';

  @override
  String get adminAppointmentStatusPending => 'Pending';

  @override
  String get adminAppointmentStatusScheduled => 'Scheduled';

  @override
  String get adminAppointmentStatusBooked => 'Booked';

  @override
  String get adminDoctorSuspendedAppointmentsWarning =>
      'Suspension does not change existing appointments or reserved slots. Follow up operationally with affected patients.';

  @override
  String get adminDoctorAuditHistory => 'Administrative history';

  @override
  String get adminDoctorAuditEmpty =>
      'No administrative actions have been recorded.';

  @override
  String get adminDoctorAuditUnavailable =>
      'Administrative history could not be loaded.';

  @override
  String get adminDoctorActor => 'Actor UID';

  @override
  String get adminDoctorReason => 'Reason';

  @override
  String get adminDoctorPreviousStatus => 'Previous status';

  @override
  String get adminDoctorNewStatus => 'New status';

  @override
  String get adminDoctorApprove => 'Approve';

  @override
  String get adminDoctorReject => 'Reject';

  @override
  String get adminDoctorSuspend => 'Suspend';

  @override
  String get adminDoctorRestore => 'Restore';

  @override
  String get adminDoctorActionReason => 'Reason';

  @override
  String get adminDoctorReasonRequired => 'Enter a reason to continue.';

  @override
  String get adminDoctorConfirmApprove =>
      'Approve this doctor? They can provide services after approval.';

  @override
  String get adminDoctorConfirmReject =>
      'Reject this doctor? They will not be able to receive bookings.';

  @override
  String get adminDoctorConfirmSuspend =>
      'Suspend this doctor? Existing appointments and slots will remain unchanged.';

  @override
  String get adminDoctorConfirmRestore =>
      'Restore this doctor? Their approved status will remain unchanged.';

  @override
  String get adminDoctorActionSuccess => 'Doctor status updated successfully.';

  @override
  String get adminDoctorActionError =>
      'The action could not be completed. Refresh the record and retry.';

  @override
  String get adminDoctorDetailsError => 'Doctor details could not be loaded.';

  @override
  String get adminDoctorActionApprove => 'Approve';

  @override
  String get adminDoctorActionReject => 'Reject';

  @override
  String get adminDoctorActionSuspend => 'Suspend';

  @override
  String get adminDoctorActionRestore => 'Restore';

  @override
  String get adminPatientsTitle => 'Patient directory';

  @override
  String get adminPatientsSearch => 'Search by patient name or email';

  @override
  String get adminPatientsSearchHint =>
      'Search matches name or email prefixes. Name matching is case-sensitive; use an email prefix containing @ to search email.';

  @override
  String get adminPatientsClearSearch => 'Clear search';

  @override
  String get adminPatientsEmpty => 'No registered patients were found.';

  @override
  String get adminPatientsNoResults => 'No patients match this search.';

  @override
  String get adminPatientsLoadError =>
      'Patients could not be loaded. Check admin access and your connection, then retry.';

  @override
  String get adminPatientsRetryLoadingMore =>
      'Could not load more patients. Retry';

  @override
  String get adminPatientNameUnavailable => 'Name unavailable';

  @override
  String adminPatientRegistered(Object date) {
    return 'Registered $date';
  }

  @override
  String get adminPatientDetailsTitle => 'Patient details';

  @override
  String get adminPatientDetailsError => 'Patient details could not be loaded.';

  @override
  String get adminPatientNotFound => 'This patient profile was not found.';

  @override
  String get adminPatientProfileCompleteness => 'Profile completeness';

  @override
  String adminPatientCompletenessPercent(int percent) {
    return '$percent% complete';
  }

  @override
  String get adminPatientRole => 'Role';

  @override
  String get adminPatientRoleValue => 'Patient';

  @override
  String get adminPatientAccountCreated => 'Account created';

  @override
  String get adminPatientLastUpdated => 'Last updated';

  @override
  String get adminPatientAppointments => 'Appointment history';

  @override
  String get adminPatientAppointmentsEmpty =>
      'No appointment history was found.';

  @override
  String get adminPatientAppointmentsError =>
      'Appointment history could not be loaded.';

  @override
  String get adminPatientUpcoming => 'Upcoming';

  @override
  String get adminPatientCompleted => 'Completed';

  @override
  String get adminPatientCancelled => 'Cancelled';

  @override
  String get adminPatientOtherAppointments => 'Other appointments';

  @override
  String get cancel => 'Cancel';

  @override
  String get retry => 'Retry';

  @override
  String get signOut => 'Sign out';

  @override
  String get accountStatusTitle => 'Account status';

  @override
  String get doctorApprovalPendingTitle => 'Approval pending';

  @override
  String get doctorApprovalPendingMessage =>
      'Your doctor account is awaiting approval. You can sign in again later.';

  @override
  String get doctorRejectedTitle => 'Account not approved';

  @override
  String get doctorRejectedMessage =>
      'Your doctor account was not approved. Contact support if you believe this is an error.';

  @override
  String get doctorSuspendedTitle => 'Doctor account suspended';

  @override
  String get doctorSuspendedMessage =>
      'Your doctor account is temporarily restricted. Contact support for more information.';

  @override
  String get doctorProfileMissingTitle => 'Account setup incomplete';

  @override
  String get doctorProfileMissingMessage =>
      'We could not verify a doctor profile for your account. Please contact support.';

  @override
  String get doctorAccessUnavailableTitle => 'Account access unavailable';

  @override
  String get doctorAccessUnavailableMessage =>
      'We could not verify your account access. Please contact support.';
}
