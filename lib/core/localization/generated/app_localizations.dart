import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'BookEase'**
  String get appName;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to BookEase'**
  String get welcome;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Book your healthcare appointments with ease.'**
  String get welcomeSubtitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @appointments.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get appointments;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @searchDoctors.
  ///
  /// In en, this message translates to:
  /// **'Search doctors or specialties'**
  String get searchDoctors;

  /// No description provided for @specialties.
  ///
  /// In en, this message translates to:
  /// **'Specialties'**
  String get specialties;

  /// No description provided for @featuredDoctors.
  ///
  /// In en, this message translates to:
  /// **'Featured Doctors'**
  String get featuredDoctors;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @adminDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin dashboard'**
  String get adminDashboardTitle;

  /// No description provided for @adminDashboardOverview.
  ///
  /// In en, this message translates to:
  /// **'Platform overview'**
  String get adminDashboardOverview;

  /// No description provided for @adminDashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A live snapshot of activity across BookEase.'**
  String get adminDashboardSubtitle;

  /// No description provided for @adminTotalPatients.
  ///
  /// In en, this message translates to:
  /// **'Total patients'**
  String get adminTotalPatients;

  /// No description provided for @adminTotalDoctors.
  ///
  /// In en, this message translates to:
  /// **'Total doctors'**
  String get adminTotalDoctors;

  /// No description provided for @adminPendingDoctors.
  ///
  /// In en, this message translates to:
  /// **'Pending doctors'**
  String get adminPendingDoctors;

  /// No description provided for @adminApprovedDoctors.
  ///
  /// In en, this message translates to:
  /// **'Approved doctors'**
  String get adminApprovedDoctors;

  /// No description provided for @adminTotalSpecialties.
  ///
  /// In en, this message translates to:
  /// **'Total specialties'**
  String get adminTotalSpecialties;

  /// No description provided for @adminTotalAppointments.
  ///
  /// In en, this message translates to:
  /// **'Total appointments'**
  String get adminTotalAppointments;

  /// No description provided for @adminUpcomingAppointments.
  ///
  /// In en, this message translates to:
  /// **'Upcoming appointments'**
  String get adminUpcomingAppointments;

  /// No description provided for @adminCompletedAppointments.
  ///
  /// In en, this message translates to:
  /// **'Completed appointments'**
  String get adminCompletedAppointments;

  /// No description provided for @adminMetricUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get adminMetricUnavailable;

  /// No description provided for @adminDashboardUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Dashboard unavailable'**
  String get adminDashboardUnavailable;

  /// No description provided for @adminDashboardLoadError.
  ///
  /// In en, this message translates to:
  /// **'Dashboard statistics could not be loaded. Check your connection and admin access, then try again.'**
  String get adminDashboardLoadError;

  /// No description provided for @adminDashboardRefreshError.
  ///
  /// In en, this message translates to:
  /// **'The latest statistics could not be refreshed. Showing the last available data.'**
  String get adminDashboardRefreshError;

  /// No description provided for @adminDashboardPartialError.
  ///
  /// In en, this message translates to:
  /// **'Some statistics are unavailable. Check your access and try again.'**
  String get adminDashboardPartialError;

  /// No description provided for @adminDoctorsTitle.
  ///
  /// In en, this message translates to:
  /// **'Doctor management'**
  String get adminDoctorsTitle;

  /// No description provided for @adminDoctorsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review doctor profiles and manage their access.'**
  String get adminDoctorsSubtitle;

  /// No description provided for @adminDoctorsSearch.
  ///
  /// In en, this message translates to:
  /// **'Search name or email'**
  String get adminDoctorsSearch;

  /// No description provided for @adminDoctorsAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get adminDoctorsAll;

  /// No description provided for @adminDoctorsPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get adminDoctorsPending;

  /// No description provided for @adminDoctorsApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get adminDoctorsApproved;

  /// No description provided for @adminDoctorsRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get adminDoctorsRejected;

  /// No description provided for @adminDoctorsSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get adminDoctorsSuspended;

  /// No description provided for @adminDoctorsSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Specialty'**
  String get adminDoctorsSpecialty;

  /// No description provided for @adminDoctorsAllSpecialties.
  ///
  /// In en, this message translates to:
  /// **'All specialties'**
  String get adminDoctorsAllSpecialties;

  /// No description provided for @adminDoctorsNeedsReview.
  ///
  /// In en, this message translates to:
  /// **'Needs review'**
  String get adminDoctorsNeedsReview;

  /// No description provided for @adminDoctorsLegacyNotice.
  ///
  /// In en, this message translates to:
  /// **'All includes legacy or malformed profiles. Status filters require a stored approval status; approved includes legacy active defaults. Search by email to find doctor users without a linked profile.'**
  String get adminDoctorsLegacyNotice;

  /// No description provided for @adminDoctorsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No doctors match these filters.'**
  String get adminDoctorsEmpty;

  /// No description provided for @adminDoctorsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Doctors could not be loaded. Check access and connection, then retry.'**
  String get adminDoctorsLoadError;

  /// No description provided for @adminDoctorsSpecialtiesUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Specialty filtering is unavailable.'**
  String get adminDoctorsSpecialtiesUnavailable;

  /// No description provided for @adminDoctorsLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get adminDoctorsLoadMore;

  /// No description provided for @adminDoctorDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Doctor details'**
  String get adminDoctorDetailsTitle;

  /// No description provided for @adminDoctorProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile information'**
  String get adminDoctorProfile;

  /// No description provided for @adminDoctorIdentity.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get adminDoctorIdentity;

  /// No description provided for @adminDoctorProfileId.
  ///
  /// In en, this message translates to:
  /// **'Profile ID'**
  String get adminDoctorProfileId;

  /// No description provided for @adminDoctorUid.
  ///
  /// In en, this message translates to:
  /// **'User UID'**
  String get adminDoctorUid;

  /// No description provided for @adminDoctorEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get adminDoctorEmail;

  /// No description provided for @adminDoctorPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get adminDoctorPhone;

  /// No description provided for @adminDoctorSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Specialty'**
  String get adminDoctorSpecialty;

  /// No description provided for @adminDoctorFee.
  ///
  /// In en, this message translates to:
  /// **'Consultation fee'**
  String get adminDoctorFee;

  /// No description provided for @adminDoctorBiography.
  ///
  /// In en, this message translates to:
  /// **'Biography'**
  String get adminDoctorBiography;

  /// No description provided for @adminDoctorQualifications.
  ///
  /// In en, this message translates to:
  /// **'Qualifications'**
  String get adminDoctorQualifications;

  /// No description provided for @adminDoctorExperience.
  ///
  /// In en, this message translates to:
  /// **'Years of experience'**
  String get adminDoctorExperience;

  /// No description provided for @adminDoctorClinic.
  ///
  /// In en, this message translates to:
  /// **'Clinic'**
  String get adminDoctorClinic;

  /// No description provided for @adminDoctorAddress.
  ///
  /// In en, this message translates to:
  /// **'Clinic address'**
  String get adminDoctorAddress;

  /// No description provided for @adminDoctorApprovalStatus.
  ///
  /// In en, this message translates to:
  /// **'Approval status'**
  String get adminDoctorApprovalStatus;

  /// No description provided for @adminDoctorAdministrativeStatus.
  ///
  /// In en, this message translates to:
  /// **'Administrative status'**
  String get adminDoctorAdministrativeStatus;

  /// No description provided for @adminDoctorActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get adminDoctorActive;

  /// No description provided for @adminDoctorNeedsReviewMessage.
  ///
  /// In en, this message translates to:
  /// **'This record needs manual review. Lifecycle actions are disabled until its identity and status are valid.'**
  String get adminDoctorNeedsReviewMessage;

  /// No description provided for @adminDoctorMissingUser.
  ///
  /// In en, this message translates to:
  /// **'Linked user record is missing.'**
  String get adminDoctorMissingUser;

  /// No description provided for @adminDoctorMissingProfile.
  ///
  /// In en, this message translates to:
  /// **'No doctor profile is linked to this doctor user.'**
  String get adminDoctorMissingProfile;

  /// No description provided for @adminDoctorRoleMismatch.
  ///
  /// In en, this message translates to:
  /// **'Linked user is not registered with the doctor role.'**
  String get adminDoctorRoleMismatch;

  /// No description provided for @adminDoctorIdentityMissing.
  ///
  /// In en, this message translates to:
  /// **'A unique doctor identity could not be resolved.'**
  String get adminDoctorIdentityMissing;

  /// No description provided for @adminDoctorIdentityLegacy.
  ///
  /// In en, this message translates to:
  /// **'Legacy profile link is in use.'**
  String get adminDoctorIdentityLegacy;

  /// No description provided for @adminDoctorIdentityMismatch.
  ///
  /// In en, this message translates to:
  /// **'Doctor profile and user links conflict.'**
  String get adminDoctorIdentityMismatch;

  /// No description provided for @adminDoctorIdentityAmbiguous.
  ///
  /// In en, this message translates to:
  /// **'Multiple doctor profiles are linked to this user.'**
  String get adminDoctorIdentityAmbiguous;

  /// No description provided for @adminDoctorStatusMissing.
  ///
  /// In en, this message translates to:
  /// **'A lifecycle status is missing; the compatibility default is shown.'**
  String get adminDoctorStatusMissing;

  /// No description provided for @adminDoctorInvalidStatus.
  ///
  /// In en, this message translates to:
  /// **'Lifecycle status is invalid or internally inconsistent.'**
  String get adminDoctorInvalidStatus;

  /// No description provided for @adminDoctorIncompleteProfile.
  ///
  /// In en, this message translates to:
  /// **'Some profile information is missing.'**
  String get adminDoctorIncompleteProfile;

  /// No description provided for @adminDoctorAppointments.
  ///
  /// In en, this message translates to:
  /// **'Upcoming appointments'**
  String get adminDoctorAppointments;

  /// No description provided for @adminDoctorNoAppointments.
  ///
  /// In en, this message translates to:
  /// **'No upcoming appointments were found.'**
  String get adminDoctorNoAppointments;

  /// No description provided for @adminDoctorAppointmentsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Upcoming appointments could not be loaded.'**
  String get adminDoctorAppointmentsUnavailable;

  /// No description provided for @adminAppointmentStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get adminAppointmentStatusConfirmed;

  /// No description provided for @adminAppointmentStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get adminAppointmentStatusPending;

  /// No description provided for @adminAppointmentStatusScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get adminAppointmentStatusScheduled;

  /// No description provided for @adminAppointmentStatusBooked.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get adminAppointmentStatusBooked;

  /// No description provided for @adminDoctorSuspendedAppointmentsWarning.
  ///
  /// In en, this message translates to:
  /// **'Suspension does not change existing appointments or reserved slots. Follow up operationally with affected patients.'**
  String get adminDoctorSuspendedAppointmentsWarning;

  /// No description provided for @adminDoctorAuditHistory.
  ///
  /// In en, this message translates to:
  /// **'Administrative history'**
  String get adminDoctorAuditHistory;

  /// No description provided for @adminDoctorAuditEmpty.
  ///
  /// In en, this message translates to:
  /// **'No administrative actions have been recorded.'**
  String get adminDoctorAuditEmpty;

  /// No description provided for @adminDoctorAuditUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Administrative history could not be loaded.'**
  String get adminDoctorAuditUnavailable;

  /// No description provided for @adminDoctorActor.
  ///
  /// In en, this message translates to:
  /// **'Actor UID'**
  String get adminDoctorActor;

  /// No description provided for @adminDoctorReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get adminDoctorReason;

  /// No description provided for @adminDoctorPreviousStatus.
  ///
  /// In en, this message translates to:
  /// **'Previous status'**
  String get adminDoctorPreviousStatus;

  /// No description provided for @adminDoctorNewStatus.
  ///
  /// In en, this message translates to:
  /// **'New status'**
  String get adminDoctorNewStatus;

  /// No description provided for @adminDoctorApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get adminDoctorApprove;

  /// No description provided for @adminDoctorReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get adminDoctorReject;

  /// No description provided for @adminDoctorSuspend.
  ///
  /// In en, this message translates to:
  /// **'Suspend'**
  String get adminDoctorSuspend;

  /// No description provided for @adminDoctorRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get adminDoctorRestore;

  /// No description provided for @adminDoctorActionReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get adminDoctorActionReason;

  /// No description provided for @adminDoctorReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a reason to continue.'**
  String get adminDoctorReasonRequired;

  /// No description provided for @adminDoctorConfirmApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve this doctor? They can provide services after approval.'**
  String get adminDoctorConfirmApprove;

  /// No description provided for @adminDoctorConfirmReject.
  ///
  /// In en, this message translates to:
  /// **'Reject this doctor? They will not be able to receive bookings.'**
  String get adminDoctorConfirmReject;

  /// No description provided for @adminDoctorConfirmSuspend.
  ///
  /// In en, this message translates to:
  /// **'Suspend this doctor? Existing appointments and slots will remain unchanged.'**
  String get adminDoctorConfirmSuspend;

  /// No description provided for @adminDoctorConfirmRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore this doctor? Their approved status will remain unchanged.'**
  String get adminDoctorConfirmRestore;

  /// No description provided for @adminDoctorActionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Doctor status updated successfully.'**
  String get adminDoctorActionSuccess;

  /// No description provided for @adminDoctorActionError.
  ///
  /// In en, this message translates to:
  /// **'The action could not be completed. Refresh the record and retry.'**
  String get adminDoctorActionError;

  /// No description provided for @adminDoctorDetailsError.
  ///
  /// In en, this message translates to:
  /// **'Doctor details could not be loaded.'**
  String get adminDoctorDetailsError;

  /// No description provided for @adminDoctorActionApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get adminDoctorActionApprove;

  /// No description provided for @adminDoctorActionReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get adminDoctorActionReject;

  /// No description provided for @adminDoctorActionSuspend.
  ///
  /// In en, this message translates to:
  /// **'Suspend'**
  String get adminDoctorActionSuspend;

  /// No description provided for @adminDoctorActionRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get adminDoctorActionRestore;

  /// No description provided for @adminPatientsTitle.
  ///
  /// In en, this message translates to:
  /// **'Patient directory'**
  String get adminPatientsTitle;

  /// No description provided for @adminPatientsSearch.
  ///
  /// In en, this message translates to:
  /// **'Search by patient name or email'**
  String get adminPatientsSearch;

  /// No description provided for @adminPatientsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search matches name or email prefixes. Name matching is case-sensitive; use an email prefix containing @ to search email.'**
  String get adminPatientsSearchHint;

  /// No description provided for @adminPatientsClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get adminPatientsClearSearch;

  /// No description provided for @adminPatientsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No registered patients were found.'**
  String get adminPatientsEmpty;

  /// No description provided for @adminPatientsNoResults.
  ///
  /// In en, this message translates to:
  /// **'No patients match this search.'**
  String get adminPatientsNoResults;

  /// No description provided for @adminPatientsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Patients could not be loaded. Check admin access and your connection, then retry.'**
  String get adminPatientsLoadError;

  /// No description provided for @adminPatientsRetryLoadingMore.
  ///
  /// In en, this message translates to:
  /// **'Could not load more patients. Retry'**
  String get adminPatientsRetryLoadingMore;

  /// No description provided for @adminPatientNameUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Name unavailable'**
  String get adminPatientNameUnavailable;

  /// No description provided for @adminPatientRegistered.
  ///
  /// In en, this message translates to:
  /// **'Registered {date}'**
  String adminPatientRegistered(Object date);

  /// No description provided for @adminPatientDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Patient details'**
  String get adminPatientDetailsTitle;

  /// No description provided for @adminPatientDetailsError.
  ///
  /// In en, this message translates to:
  /// **'Patient details could not be loaded.'**
  String get adminPatientDetailsError;

  /// No description provided for @adminPatientNotFound.
  ///
  /// In en, this message translates to:
  /// **'This patient profile was not found.'**
  String get adminPatientNotFound;

  /// No description provided for @adminPatientProfileCompleteness.
  ///
  /// In en, this message translates to:
  /// **'Profile completeness'**
  String get adminPatientProfileCompleteness;

  /// No description provided for @adminPatientCompletenessPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete'**
  String adminPatientCompletenessPercent(int percent);

  /// No description provided for @adminPatientRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get adminPatientRole;

  /// No description provided for @adminPatientRoleValue.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get adminPatientRoleValue;

  /// No description provided for @adminPatientAccountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created'**
  String get adminPatientAccountCreated;

  /// No description provided for @adminPatientLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated'**
  String get adminPatientLastUpdated;

  /// No description provided for @adminPatientAppointments.
  ///
  /// In en, this message translates to:
  /// **'Appointment history'**
  String get adminPatientAppointments;

  /// No description provided for @adminPatientAppointmentsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No appointment history was found.'**
  String get adminPatientAppointmentsEmpty;

  /// No description provided for @adminPatientAppointmentsError.
  ///
  /// In en, this message translates to:
  /// **'Appointment history could not be loaded.'**
  String get adminPatientAppointmentsError;

  /// No description provided for @adminPatientUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get adminPatientUpcoming;

  /// No description provided for @adminPatientCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get adminPatientCompleted;

  /// No description provided for @adminPatientCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get adminPatientCancelled;

  /// No description provided for @adminPatientOtherAppointments.
  ///
  /// In en, this message translates to:
  /// **'Other appointments'**
  String get adminPatientOtherAppointments;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @accountStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Account status'**
  String get accountStatusTitle;

  /// No description provided for @doctorApprovalPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Approval pending'**
  String get doctorApprovalPendingTitle;

  /// No description provided for @doctorApprovalPendingMessage.
  ///
  /// In en, this message translates to:
  /// **'Your doctor account is awaiting approval. You can sign in again later.'**
  String get doctorApprovalPendingMessage;

  /// No description provided for @doctorRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Account not approved'**
  String get doctorRejectedTitle;

  /// No description provided for @doctorRejectedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your doctor account was not approved. Contact support if you believe this is an error.'**
  String get doctorRejectedMessage;

  /// No description provided for @doctorSuspendedTitle.
  ///
  /// In en, this message translates to:
  /// **'Doctor account suspended'**
  String get doctorSuspendedTitle;

  /// No description provided for @doctorSuspendedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your doctor account is temporarily restricted. Contact support for more information.'**
  String get doctorSuspendedMessage;

  /// No description provided for @doctorProfileMissingTitle.
  ///
  /// In en, this message translates to:
  /// **'Account setup incomplete'**
  String get doctorProfileMissingTitle;

  /// No description provided for @doctorProfileMissingMessage.
  ///
  /// In en, this message translates to:
  /// **'We could not verify a doctor profile for your account. Please contact support.'**
  String get doctorProfileMissingMessage;

  /// No description provided for @doctorAccessUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Account access unavailable'**
  String get doctorAccessUnavailableTitle;

  /// No description provided for @doctorAccessUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'We could not verify your account access. Please contact support.'**
  String get doctorAccessUnavailableMessage;

  /// No description provided for @doctorProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Doctor profile'**
  String get doctorProfileTitle;

  /// No description provided for @doctorProfileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get doctorProfileEdit;

  /// No description provided for @doctorProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change profile photo'**
  String get doctorProfilePhoto;

  /// No description provided for @doctorProfileSave.
  ///
  /// In en, this message translates to:
  /// **'Save profile'**
  String get doctorProfileSave;

  /// No description provided for @doctorProfileSpecialtyReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Specialty changes require admin review and are not editable here.'**
  String get doctorProfileSpecialtyReadOnly;

  /// No description provided for @doctorProfileCompleteness.
  ///
  /// In en, this message translates to:
  /// **'Profile completeness'**
  String get doctorProfileCompleteness;

  /// No description provided for @doctorProfileSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile saved.'**
  String get doctorProfileSaveSuccess;

  /// No description provided for @doctorProfilePhotoSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated.'**
  String get doctorProfilePhotoSuccess;

  /// No description provided for @patientBecomeDoctor.
  ///
  /// In en, this message translates to:
  /// **'Become a doctor'**
  String get patientBecomeDoctor;

  /// No description provided for @patientBecomeDoctorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Apply to join BookEase as a medical professional.'**
  String get patientBecomeDoctorSubtitle;

  /// No description provided for @doctorApplicationTitle.
  ///
  /// In en, this message translates to:
  /// **'Doctor application'**
  String get doctorApplicationTitle;

  /// No description provided for @doctorApplicationStatus.
  ///
  /// In en, this message translates to:
  /// **'Application status'**
  String get doctorApplicationStatus;

  /// No description provided for @doctorApplicationNoApplication.
  ///
  /// In en, this message translates to:
  /// **'You have not submitted a doctor application yet.'**
  String get doctorApplicationNoApplication;

  /// No description provided for @doctorApplicationPending.
  ///
  /// In en, this message translates to:
  /// **'Your application is under review.'**
  String get doctorApplicationPending;

  /// No description provided for @doctorApplicationApproved.
  ///
  /// In en, this message translates to:
  /// **'Your application was approved.'**
  String get doctorApplicationApproved;

  /// No description provided for @doctorApplicationRejected.
  ///
  /// In en, this message translates to:
  /// **'Your application was not approved.'**
  String get doctorApplicationRejected;

  /// No description provided for @doctorApplicationSubmittedOn.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get doctorApplicationSubmittedOn;

  /// No description provided for @doctorApplicationReviewedOn.
  ///
  /// In en, this message translates to:
  /// **'Reviewed'**
  String get doctorApplicationReviewedOn;

  /// No description provided for @doctorApplicationRejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Review notes'**
  String get doctorApplicationRejectionReason;

  /// No description provided for @doctorApplicationStart.
  ///
  /// In en, this message translates to:
  /// **'Start application'**
  String get doctorApplicationStart;

  /// No description provided for @doctorApplicationResubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit a new application'**
  String get doctorApplicationResubmit;

  /// No description provided for @doctorApplicationFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Apply as a doctor'**
  String get doctorApplicationFormTitle;

  /// No description provided for @doctorApplicationFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get doctorApplicationFullName;

  /// No description provided for @doctorApplicationPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get doctorApplicationPhone;

  /// No description provided for @doctorApplicationSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Specialty'**
  String get doctorApplicationSpecialty;

  /// No description provided for @doctorApplicationQualification.
  ///
  /// In en, this message translates to:
  /// **'Medical qualification'**
  String get doctorApplicationQualification;

  /// No description provided for @doctorApplicationExperience.
  ///
  /// In en, this message translates to:
  /// **'Years of experience'**
  String get doctorApplicationExperience;

  /// No description provided for @doctorApplicationBio.
  ///
  /// In en, this message translates to:
  /// **'Professional biography'**
  String get doctorApplicationBio;

  /// No description provided for @doctorApplicationFee.
  ///
  /// In en, this message translates to:
  /// **'Consultation fee'**
  String get doctorApplicationFee;

  /// No description provided for @doctorApplicationClinicAddress.
  ///
  /// In en, this message translates to:
  /// **'Clinic address'**
  String get doctorApplicationClinicAddress;

  /// No description provided for @doctorApplicationCredentialNotice.
  ///
  /// In en, this message translates to:
  /// **'Professional details are self-reported. An administrator may request verification before or after review.'**
  String get doctorApplicationCredentialNotice;

  /// No description provided for @doctorApplicationSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit for review'**
  String get doctorApplicationSubmit;

  /// No description provided for @doctorApplicationSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Application submitted for review.'**
  String get doctorApplicationSubmitted;

  /// No description provided for @doctorApplicationAlreadyPending.
  ///
  /// In en, this message translates to:
  /// **'An application is already under review.'**
  String get doctorApplicationAlreadyPending;

  /// No description provided for @doctorApplicationValidationRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get doctorApplicationValidationRequired;

  /// No description provided for @doctorApplicationValidationPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number.'**
  String get doctorApplicationValidationPhone;

  /// No description provided for @doctorApplicationValidationFee.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid non-negative fee.'**
  String get doctorApplicationValidationFee;

  /// No description provided for @doctorApplicationValidationExperience.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number of years.'**
  String get doctorApplicationValidationExperience;

  /// No description provided for @doctorApplicationValidationBio.
  ///
  /// In en, this message translates to:
  /// **'Enter at least 30 characters.'**
  String get doctorApplicationValidationBio;

  /// No description provided for @doctorApplicationSpecialtiesUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No active specialties are available. Please contact support.'**
  String get doctorApplicationSpecialtiesUnavailable;

  /// No description provided for @doctorApplicationGoDashboard.
  ///
  /// In en, this message translates to:
  /// **'Open doctor dashboard'**
  String get doctorApplicationGoDashboard;

  /// No description provided for @adminDoctorApplications.
  ///
  /// In en, this message translates to:
  /// **'Doctor applications'**
  String get adminDoctorApplications;

  /// No description provided for @adminDoctorApplicationsSearch.
  ///
  /// In en, this message translates to:
  /// **'Search name or email prefix'**
  String get adminDoctorApplicationsSearch;

  /// No description provided for @adminDoctorApplicationsAll.
  ///
  /// In en, this message translates to:
  /// **'All statuses'**
  String get adminDoctorApplicationsAll;

  /// No description provided for @adminDoctorApplicationsPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get adminDoctorApplicationsPending;

  /// No description provided for @adminDoctorApplicationsApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get adminDoctorApplicationsApproved;

  /// No description provided for @adminDoctorApplicationsRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get adminDoctorApplicationsRejected;

  /// No description provided for @adminDoctorApplicationsAllSpecialties.
  ///
  /// In en, this message translates to:
  /// **'All specialties'**
  String get adminDoctorApplicationsAllSpecialties;

  /// No description provided for @adminDoctorApplicationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No applications match these filters.'**
  String get adminDoctorApplicationsEmpty;

  /// No description provided for @adminDoctorApplicationsEnd.
  ///
  /// In en, this message translates to:
  /// **'You have reached the end of the applications.'**
  String get adminDoctorApplicationsEnd;

  /// No description provided for @adminDoctorApplicationDetails.
  ///
  /// In en, this message translates to:
  /// **'Application details'**
  String get adminDoctorApplicationDetails;

  /// No description provided for @adminDoctorApplicationAccount.
  ///
  /// In en, this message translates to:
  /// **'Applicant account'**
  String get adminDoctorApplicationAccount;

  /// No description provided for @adminDoctorApplicationHistory.
  ///
  /// In en, this message translates to:
  /// **'Application history'**
  String get adminDoctorApplicationHistory;

  /// No description provided for @adminDoctorApplicationUid.
  ///
  /// In en, this message translates to:
  /// **'Applicant UID'**
  String get adminDoctorApplicationUid;

  /// No description provided for @adminDoctorApplicationRole.
  ///
  /// In en, this message translates to:
  /// **'Current account role'**
  String get adminDoctorApplicationRole;

  /// No description provided for @adminDoctorApplicationReviewer.
  ///
  /// In en, this message translates to:
  /// **'Reviewer UID'**
  String get adminDoctorApplicationReviewer;

  /// No description provided for @adminDoctorApplicationApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve and create doctor profile'**
  String get adminDoctorApplicationApprove;

  /// No description provided for @adminDoctorApplicationReject.
  ///
  /// In en, this message translates to:
  /// **'Reject application'**
  String get adminDoctorApplicationReject;

  /// No description provided for @adminDoctorApplicationReasonPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter a reason for rejection'**
  String get adminDoctorApplicationReasonPrompt;

  /// No description provided for @adminDoctorApplicationReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'A reason is required.'**
  String get adminDoctorApplicationReasonRequired;

  /// No description provided for @adminDoctorApplicationRetry.
  ///
  /// In en, this message translates to:
  /// **'Could not complete the review. Please retry.'**
  String get adminDoctorApplicationRetry;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
