import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/firebase/specialty_status.dart';
import '../../domain/entities/doctor_application.dart';
import '../../domain/entities/doctor_application_page.dart';
import '../../domain/errors/doctor_application_exception.dart';
import '../models/doctor_application_model.dart';

class DoctorApplicationRemoteDataSource {
  DoctorApplicationRemoteDataSource(this._firestore, this._firebaseAuth);

  static const _pageSize = 20;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  Future<DoctorApplication?> getLatestForCurrentUser() async {
    final uid = _currentUid();
    final snapshot = await _firestore
        .collection('doctor_applications')
        .where('applicantUid', isEqualTo: uid)
        .orderBy('submittedAt', descending: true)
        .limit(1)
        .get();
    return snapshot.docs.isEmpty
        ? null
        : DoctorApplicationModel.fromSnapshot(snapshot.docs.first);
  }

  Future<List<DoctorApplication>> getApplicantHistory(
    String applicantUid,
  ) async {
    final snapshot = await _firestore
        .collection('doctor_applications')
        .where('applicantUid', isEqualTo: applicantUid)
        .orderBy('submittedAt', descending: true)
        .limit(20)
        .get();
    return snapshot.docs
        .map(DoctorApplicationModel.fromSnapshot)
        .whereType<DoctorApplication>()
        .toList(growable: false);
  }

  Future<List<DoctorApplicationSpecialty>> getSpecialties() async {
    final snapshot = await _firestore
        .collection('specialties')
        .orderBy('name')
        .get();
    return _mapSpecialties(snapshot);
  }

  Stream<List<DoctorApplicationSpecialty>> watchSpecialties() => _firestore
      .collection('specialties')
      .orderBy('name')
      .snapshots()
      .map(_mapSpecialties);

  List<DoctorApplicationSpecialty> _mapSpecialties(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final specialties = <DoctorApplicationSpecialty>[];
    for (final document in snapshot.docs) {
      final name = document.data()['name'];
      if (name is String &&
          name.trim().isNotEmpty &&
          specialtyIsAvailableForPatients(document.data())) {
        specialties.add(
          DoctorApplicationSpecialty(
            id: document.id,
            name: name.trim(),
            nameAr: document.data()['nameAr'] is String
                ? (document.data()['nameAr'] as String).trim()
                : '',
          ),
        );
      }
    }
    return specialties;
  }

  Future<void> submit({
    required String fullName,
    required String phoneNumber,
    required String specialtyId,
    required String qualification,
    required int experienceYears,
    required String bio,
    required double consultationFee,
    required String clinicAddress,
  }) async {
    final uid = _currentUid();
    final userReference = _firestore.collection('users').doc(uid);
    final stateReference = _firestore
        .collection('doctor_application_state')
        .doc(uid);
    final specialtyReference = _firestore
        .collection('specialties')
        .doc(specialtyId);

    final existingState = await stateReference.get();
    if (!existingState.exists) {
      final existingHistory = await _firestore
          .collection('doctor_applications')
          .where('applicantUid', isEqualTo: uid)
          .limit(1)
          .get();
      if (existingHistory.docs.isNotEmpty) {
        throw const DoctorApplicationException(
          'Application history could not be verified.',
        );
      }
    }

    await _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userReference);
      final stateSnapshot = await transaction.get(stateReference);
      final specialtySnapshot = await transaction.get(specialtyReference);
      final userData = userSnapshot.data();
      if (!userSnapshot.exists ||
          userData == null ||
          userData['role'] != 'patient' ||
          userData.containsKey('doctorProfileId')) {
        throw const DoctorApplicationException(
          'This account is not eligible to apply.',
        );
      }

      final specialtyData = specialtySnapshot.data();
      if (!specialtySnapshot.exists ||
          specialtyData == null ||
          (specialtyData.containsKey('isActive') &&
              specialtyData['isActive'] != true) ||
          specialtyData['name'] is! String ||
          (specialtyData['name'] as String).trim().isEmpty) {
        throw const DoctorApplicationException('Choose an active specialty.');
      }

      final stateData = stateSnapshot.data() ?? const <String, dynamic>{};
      final currentApplicationId = stateData['currentApplicationId'];
      final revision = stateSnapshot.exists ? stateData['nextRevision'] : 1;
      if (stateSnapshot.exists &&
          (currentApplicationId is! String ||
              currentApplicationId.isEmpty ||
              revision is! int ||
              revision < 1)) {
        throw const DoctorApplicationException(
          'Application history could not be verified.',
        );
      }

      if (stateSnapshot.exists) {
        final previousSnapshot = await transaction.get(
          _firestore
              .collection('doctor_applications')
              .doc(currentApplicationId),
        );
        final previousData = previousSnapshot.data();
        if (!previousSnapshot.exists ||
            previousData == null ||
            previousData['applicantUid'] != uid ||
            previousData['applicationStatus'] != 'rejected') {
          throw const DoctorApplicationException(
            'An application is already under review or has already been approved.',
          );
        }
      }

      final profileName = fullName.trim();
      final applicantPhone = phoneNumber.trim();
      final applicantEmail = _readRequiredUserString(userData, 'email', 254);
      final profileImageUrl = _readOptionalUserString(
        userData,
        'profileImageUrl',
        2048,
      );
      final applicationId = '${uid}_$revision';
      final applicationReference = _firestore
          .collection('doctor_applications')
          .doc(applicationId);
      final application = <String, Object>{
        'applicationId': applicationId,
        'applicantUid': uid,
        'applicantName': profileName,
        'applicantNameLower': profileName.toLowerCase(),
        'applicantEmail': applicantEmail,
        'applicantEmailLower': applicantEmail.toLowerCase(),
        'applicantPhone': applicantPhone,
        'profileImageUrl': profileImageUrl,
        'specialtyId': specialtyId,
        'specialtyName': (specialtyData['name'] as String).trim(),
        'qualification': qualification.trim(),
        'experienceYears': experienceYears,
        'bio': bio.trim(),
        'consultationFee': consultationFee,
        'clinicAddress': clinicAddress.trim(),
        'applicationStatus': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'schemaVersion': 1,
        'revision': revision,
      };

      transaction.set(applicationReference, application);
      transaction.set(stateReference, {
        'currentApplicationId': applicationId,
        'nextRevision': revision + 1,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (userData['fullName'] != profileName ||
          userData['phoneNumber'] != applicantPhone) {
        transaction.update(userReference, {
          'fullName': profileName,
          'phoneNumber': applicantPhone,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  Future<DoctorApplicationPage> getApplications({
    required String status,
    required String specialtyId,
    required String search,
    String? cursor,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection(
      'doctor_applications',
    );
    if (status != 'all') {
      query = query.where('applicationStatus', isEqualTo: status);
    }
    if (specialtyId.isNotEmpty) {
      query = query.where('specialtyId', isEqualTo: specialtyId);
    }

    final normalizedSearch = search.trim().toLowerCase();
    final sortField = normalizedSearch.isEmpty
        ? 'submittedAt'
        : normalizedSearch.contains('@')
        ? 'applicantEmailLower'
        : 'applicantNameLower';
    if (normalizedSearch.isNotEmpty) {
      query = query
          .where(sortField, isGreaterThanOrEqualTo: normalizedSearch)
          .where(sortField, isLessThanOrEqualTo: '$normalizedSearch\uf8ff');
    }
    query = query.orderBy(sortField, descending: normalizedSearch.isEmpty);
    if (cursor != null) {
      final cursorSnapshot = await _firestore
          .collection('doctor_applications')
          .doc(cursor)
          .get();
      if (!cursorSnapshot.exists) {
        throw const DoctorApplicationException(
          'The application list changed. Refresh and try again.',
        );
      }
      query = query.startAfterDocument(cursorSnapshot);
    }

    final snapshot = await query.limit(_pageSize + 1).get();
    final hasMore = snapshot.docs.length > _pageSize;
    final visibleDocuments = snapshot.docs.take(_pageSize).toList();
    return DoctorApplicationPage(
      applications: visibleDocuments
          .map(DoctorApplicationModel.fromSnapshot)
          .whereType<DoctorApplication>()
          .toList(growable: false),
      hasMore: hasMore,
      nextCursor: hasMore ? visibleDocuments.last.id : null,
    );
  }

  Future<DoctorApplication?> getApplication(String applicationId) async {
    final snapshot = await _firestore
        .collection('doctor_applications')
        .doc(applicationId)
        .get();
    return DoctorApplicationModel.fromSnapshot(snapshot);
  }

  Future<DoctorApplicantAccount?> getApplicantAccount(
    String applicantUid,
  ) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(applicantUid)
        .get();
    final data = snapshot.data();
    if (data == null) return null;
    return DoctorApplicantAccount(
      fullName: data['fullName'] is String
          ? (data['fullName'] as String).trim()
          : '',
      email: data['email'] is String ? (data['email'] as String).trim() : '',
      phoneNumber: data['phoneNumber'] is String
          ? (data['phoneNumber'] as String).trim()
          : '',
      profileImageUrl: data['profileImageUrl'] is String
          ? (data['profileImageUrl'] as String).trim()
          : '',
      role: data['role'] is String ? (data['role'] as String).trim() : '',
    );
  }

  Future<void> review({
    required String applicationId,
    required bool approve,
    String? reason,
  }) async {
    final actorUid = _currentUid();
    final trimmedReason = approve ? '' : (reason?.trim() ?? '');
    if (!approve && (trimmedReason.length < 5 || trimmedReason.length > 500)) {
      throw const DoctorApplicationException(
        'Provide a rejection reason between 5 and 500 characters.',
      );
    }

    final operationId =
        'application_${applicationId}_${approve ? 'approve' : 'reject'}';
    final applicationReference = _firestore
        .collection('doctor_applications')
        .doc(applicationId);
    final auditReference = _firestore
        .collection('doctor_application_audit')
        .doc(operationId);
    final preflightAudit = await auditReference.get();
    if (preflightAudit.exists) {
      if (_isMatchingReviewOperation(
        preflightAudit.data(),
        actorUid: actorUid,
        applicationId: applicationId,
        approve: approve,
        reason: trimmedReason,
      )) {
        return;
      }
      throw const DoctorApplicationException(
        'This review operation could not be verified.',
      );
    }

    final preflightApplication = await applicationReference.get();
    final preflightApplicantUid = preflightApplication.data()?['applicantUid'];
    if (!preflightApplication.exists ||
        preflightApplicantUid is! String ||
        preflightApplicantUid.isEmpty) {
      throw const DoctorApplicationException(
        'The requested application was not found.',
      );
    }
    if (approve) {
      final doctorMatches = await _firestore
          .collection('doctors')
          .where('uid', isEqualTo: preflightApplicantUid)
          .limit(2)
          .get();
      if (doctorMatches.docs.isNotEmpty) {
        throw const DoctorApplicationException(
          'The applicant already has a doctor profile.',
        );
      }
    }

    await _firestore.runTransaction((transaction) async {
      final auditSnapshot = await transaction.get(auditReference);
      if (auditSnapshot.exists) {
        if (_isMatchingReviewOperation(
          auditSnapshot.data(),
          actorUid: actorUid,
          applicationId: applicationId,
          approve: approve,
          reason: trimmedReason,
        )) {
          return;
        }
        throw const DoctorApplicationException(
          'This review operation could not be verified.',
        );
      }

      final applicationSnapshot = await transaction.get(applicationReference);
      final application = applicationSnapshot.data();
      if (!applicationSnapshot.exists || application == null) {
        throw const DoctorApplicationException(
          'The requested application was not found.',
        );
      }
      if (application['applicationStatus'] != 'pending') {
        throw const DoctorApplicationException(
          'Only pending applications can be reviewed.',
        );
      }

      final applicantUid = application['applicantUid'];
      if (applicantUid is! String ||
          applicantUid.isEmpty ||
          applicantUid == actorUid ||
          application['applicationId'] != applicationId) {
        throw const DoctorApplicationException(
          'This application cannot be reviewed by this account.',
        );
      }

      final userReference = _firestore.collection('users').doc(applicantUid);
      final stateReference = _firestore
          .collection('doctor_application_state')
          .doc(applicantUid);
      final legacyDoctorReference = _firestore
          .collection('doctors')
          .doc(applicantUid);
      final userSnapshot = await transaction.get(userReference);
      final stateSnapshot = await transaction.get(stateReference);
      final legacyDoctorSnapshot = await transaction.get(legacyDoctorReference);
      final userData = userSnapshot.data();
      final stateData = stateSnapshot.data();
      final revision = application['revision'];
      if (approve &&
          (!stateSnapshot.exists ||
              stateData?['currentApplicationId'] != applicationId ||
              revision is! int ||
              stateData?['nextRevision'] != revision + 1)) {
        throw const DoctorApplicationException(
          'The applicant or current application state could not be verified.',
        );
      }
      if (approve &&
          (!userSnapshot.exists ||
              userData == null ||
              userData['role'] != 'patient' ||
              userData.containsKey('doctorProfileId') ||
              legacyDoctorSnapshot.exists)) {
        throw const DoctorApplicationException(
          'The applicant already has a doctor profile or is not eligible.',
        );
      }

      final now = FieldValue.serverTimestamp();
      final event = <String, Object>{
        'actorUid': actorUid,
        'action': 'application_${approve ? 'approve' : 'reject'}',
        'applicationId': applicationId,
        'applicantUid': applicantUid,
        'operationId': operationId,
        'reason': trimmedReason,
        'schemaVersion': 1,
        'createdAt': now,
      };

      if (approve) {
        final specialtyId = _requiredString(application, 'specialtyId');
        final specialtyReference = _firestore
            .collection('specialties')
            .doc(specialtyId);
        final specialtySnapshot = await transaction.get(specialtyReference);
        final specialtyData = specialtySnapshot.data();
        if (!specialtySnapshot.exists ||
            specialtyData == null ||
            (specialtyData.containsKey('isActive') &&
                specialtyData['isActive'] != true) ||
            specialtyData['name'] is! String ||
            (specialtyData['name'] as String).trim().isEmpty) {
          throw const DoctorApplicationException(
            'The application specialty is no longer active.',
          );
        }

        final applicantName = _requiredString(application, 'applicantName');
        final applicantEmail = _requiredString(application, 'applicantEmail');
        final applicantPhone = _requiredString(application, 'applicantPhone');
        final profileImageUrl = application['profileImageUrl'];
        final qualification = _requiredString(application, 'qualification');
        final bio = _requiredString(application, 'bio');
        final clinicAddress = _requiredString(application, 'clinicAddress');
        final experienceYears = application['experienceYears'];
        final consultationFee = application['consultationFee'];
        if (experienceYears is! int ||
            experienceYears < 0 ||
            experienceYears > 80 ||
            profileImageUrl is! String ||
            profileImageUrl.length > 2048 ||
            consultationFee is! num ||
            !consultationFee.isFinite ||
            consultationFee < 0 ||
            consultationFee > 1000000 ||
            applicantName.length > 120 ||
            applicantEmail.length > 254 ||
            applicantPhone.length > 24 ||
            !RegExp(r'^[0-9+() .-]{7,24}$').hasMatch(applicantPhone) ||
            qualification.length > 250 ||
            bio.length > 5000 ||
            clinicAddress.length > 500) {
          throw const DoctorApplicationException(
            'The application contains invalid profile information.',
          );
        }

        final doctorProfileId = 'doctor_$applicationId';
        final doctorReference = _firestore
            .collection('doctors')
            .doc(doctorProfileId);
        final doctorSnapshot = await transaction.get(doctorReference);
        if (doctorSnapshot.exists) {
          throw const DoctorApplicationException(
            'The doctor profile ID is already in use.',
          );
        }
        final doctorProfile = <String, Object>{
          'uid': applicantUid,
          'fullName': applicantName,
          'email': applicantEmail,
          'phoneNumber': applicantPhone,
          'profileImageUrl': profileImageUrl.trim(),
          'specialtyId': specialtyId,
          'specialtyName': (specialtyData['name'] as String).trim(),
          'qualifications': [qualification],
          'yearsExperience': experienceYears,
          'biography': bio,
          'consultationFee': consultationFee,
          'clinicAddress': clinicAddress,
          'approvalStatus': 'approved',
          'administrativeStatus': 'active',
          'applicationId': applicationId,
          'createdAt': now,
          'updatedAt': now,
        };
        transaction.set(doctorReference, doctorProfile);
        transaction.update(userReference, {
          'role': 'doctor',
          'doctorProfileId': doctorProfileId,
          'fullName': applicantName,
          'phoneNumber': applicantPhone,
          'updatedAt': now,
        });
        transaction.update(applicationReference, {
          'applicationStatus': 'approved',
          'reviewedBy': actorUid,
          'reviewedAt': now,
          'doctorProfileId': doctorProfileId,
          'updatedAt': now,
        });
        event['doctorProfileId'] = doctorProfileId;
        event['newRole'] = 'doctor';
      } else {
        transaction.update(applicationReference, {
          'applicationStatus': 'rejected',
          'reviewedBy': actorUid,
          'reviewedAt': now,
          'rejectionReason': trimmedReason,
          'updatedAt': now,
        });
      }

      transaction.set(auditReference, event);
    });
  }

  String _currentUid() {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw const DoctorApplicationException('Sign in to view applications.');
    }
    return uid;
  }

  String _requiredString(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is! String || value.trim().isEmpty) {
      throw const DoctorApplicationException(
        'The application contains incomplete profile information.',
      );
    }
    return value.trim();
  }

  bool _isMatchingReviewOperation(
    Map<String, dynamic>? audit, {
    required String actorUid,
    required String applicationId,
    required bool approve,
    required String reason,
  }) =>
      audit?['actorUid'] == actorUid &&
      audit?['applicationId'] == applicationId &&
      audit?['action'] == 'application_${approve ? 'approve' : 'reject'}' &&
      audit?['reason'] == reason;

  String _readRequiredUserString(
    Map<String, dynamic> userData,
    String key,
    int maxLength,
  ) {
    final value = userData[key];
    if (value is! String ||
        value.trim().isEmpty ||
        value.trim().length > maxLength) {
      throw const DoctorApplicationException(
        'Complete your account profile before applying.',
      );
    }
    return value.trim();
  }

  String _readOptionalUserString(
    Map<String, dynamic> userData,
    String key,
    int maxLength,
  ) {
    final value = userData[key];
    if (value == null || value == '') return '';
    if (value is! String || value.trim().length > maxLength) {
      throw const DoctorApplicationException(
        'Complete your account profile before applying.',
      );
    }
    return value.trim();
  }
}
