import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/doctor_application.dart';
import '../../domain/entities/doctor_application_page.dart';
import '../../domain/errors/doctor_application_exception.dart';
import '../models/doctor_application_model.dart';

class DoctorApplicationRemoteDataSource {
  DoctorApplicationRemoteDataSource(
    this._firestore,
    this._firebaseAuth, {
    FirebaseFunctions? functions,
  }) : _functions =
           functions ?? FirebaseFunctions.instanceFor(region: 'us-central1');

  static const _pageSize = 20;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;
  final FirebaseFunctions _functions;
  final Random _random = Random.secure();

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
    final snapshot = await _firestore.collection('specialties').get();
    final specialties = <DoctorApplicationSpecialty>[];
    for (final document in snapshot.docs) {
      final name = document.data()['name'];
      if (name is String &&
          name.trim().isNotEmpty &&
          document.data()['isActive'] != false) {
        specialties.add(
          DoctorApplicationSpecialty(id: document.id, name: name.trim()),
        );
      }
    }
    specialties.sort((first, second) => first.name.compareTo(second.name));
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
    await _functions.httpsCallable('submitDoctorApplication').call({
      'fullName': fullName.trim(),
      'phoneNumber': phoneNumber.trim(),
      'specialtyId': specialtyId,
      'qualification': qualification.trim(),
      'experienceYears': experienceYears,
      'bio': bio.trim(),
      'consultationFee': consultationFee,
      'clinicAddress': clinicAddress.trim(),
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
    final operationId =
        'application-${DateTime.now().microsecondsSinceEpoch}-${_random.nextInt(1 << 31)}';
    final callableName = approve
        ? 'approveDoctorApplication'
        : 'rejectDoctorApplication';
    final payload = <String, Object>{
      'applicationId': applicationId,
      'operationId': operationId,
      if (!approve) 'reason': reason!.trim(),
    };
    await _functions.httpsCallable(callableName).call(payload);
  }

  String _currentUid() {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw const DoctorApplicationException('Sign in to view applications.');
    }
    return uid;
  }
}
