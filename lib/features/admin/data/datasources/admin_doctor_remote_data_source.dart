import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/firebase/doctor_profile_resolver.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../domain/entities/admin_doctor.dart';
import '../../domain/entities/admin_doctor_filter.dart';
import '../../domain/errors/admin_doctor_exception.dart';
import '../models/admin_doctor_model.dart';
import '../models/admin_doctor_snapshot_mapper.dart';
import 'admin_doctor_list_data_source.dart';

class AdminDoctorRemoteDataSource implements AdminDoctorListDataSource {
  const AdminDoctorRemoteDataSource(this._firestore);

  static const _pageSize = 20;
  final FirebaseFirestore _firestore;

  @override
  Future<AdminDoctorPage> getDoctors({
    required AdminDoctorFilter filter,
    required String search,
    required String specialtyId,
    AdminDoctorCursor? cursor,
  }) async {
    try {
      final queryText = search.trim();
      if (queryText.contains('@')) {
        return await _searchByEmail(queryText, filter, specialtyId, cursor);
      }

      final field = cursor?.sortField == 'name'
          ? 'name'
          : queryText.isEmpty
          ? null
          : 'fullName';
      Query<Map<String, dynamic>> query = _firestore.collection('doctors');
      query = _applyStatus(query, filter);
      if (specialtyId.isNotEmpty) {
        query = query.where('specialtyId', isEqualTo: specialtyId);
      }
      if (field != null) {
        query = query
            .where(field, isGreaterThanOrEqualTo: queryText)
            .where(field, isLessThan: '$queryText\uf8ff')
            .orderBy(field)
            .orderBy(FieldPath.documentId);
      } else {
        query = query.orderBy(FieldPath.documentId);
      }
      query = _applyCursor(query, cursor);
      final snapshot = await query.limit(_pageSize + 1).get();
      var documents = snapshot.docs.take(_pageSize).toList();

      if (field == 'fullName' &&
          documents.isEmpty &&
          cursor?.sortField != 'name') {
        return await _searchLegacyNames(queryText, filter, specialtyId, null);
      }
      if (field == 'name') {
        documents = documents
            .where(
              (document) =>
                  (document.data()['fullName'] as String?)?.trim().isEmpty ??
                  true,
            )
            .toList();
      }

      final mapper = AdminDoctorSnapshotMapper(_firestore);
      final doctors = await Future.wait(
        documents.map((document) => mapper.map(document)),
      );
      final filteredDoctors = doctors
          .where((doctor) => _matchesFilter(doctor, filter, specialtyId))
          .toList(growable: false);
      final hasMore = field == 'fullName'
          ? true
          : snapshot.docs.length > _pageSize;
      final nextCursor = documents.isEmpty
          ? cursor
          : AdminDoctorCursor(
              documentId: documents.last.id,
              sortField: field,
              sortValue: field == null
                  ? null
                  : documents.last.data()[field] as String?,
            );
      return AdminDoctorPage(
        doctors: filteredDoctors,
        hasMore: hasMore,
        nextCursor: nextCursor,
      );
    } on FirebaseException catch (error) {
      debugPrint('Admin doctor list failed: ${error.code}');
      throw AdminDoctorException(error.code);
    }
  }

  Future<AdminDoctorPage> _searchLegacyNames(
    String search,
    AdminDoctorFilter filter,
    String specialtyId,
    AdminDoctorCursor? cursor,
  ) async {
    Query<Map<String, dynamic>> query = _firestore.collection('doctors');
    query = _applyStatus(query, filter);
    if (specialtyId.isNotEmpty) {
      query = query.where('specialtyId', isEqualTo: specialtyId);
    }
    query = query
        .where('name', isGreaterThanOrEqualTo: search)
        .where('name', isLessThan: '$search\uf8ff')
        .orderBy('name')
        .orderBy(FieldPath.documentId);
    query = _applyCursor(query, cursor);
    final snapshot = await query.limit(_pageSize + 1).get();
    final pageDocuments = snapshot.docs.take(_pageSize).toList();
    final documents = pageDocuments
        .where(
          (document) =>
              (document.data()['fullName'] as String?)?.trim().isEmpty ?? true,
        )
        .toList();
    final mapper = AdminDoctorSnapshotMapper(_firestore);
    final doctors = await Future.wait(
      documents.map((document) => mapper.map(document)),
    );
    return AdminDoctorPage(
      doctors: doctors
          .where((doctor) => _matchesFilter(doctor, filter, specialtyId))
          .toList(growable: false),
      hasMore: snapshot.docs.length > _pageSize,
      nextCursor: pageDocuments.isEmpty
          ? null
          : AdminDoctorCursor(
              documentId: pageDocuments.last.id,
              sortField: 'name',
              sortValue: pageDocuments.last.data()['name'] as String?,
            ),
    );
  }

  Future<AdminDoctorPage> _searchByEmail(
    String search,
    AdminDoctorFilter filter,
    String specialtyId,
    AdminDoctorCursor? cursor,
  ) async {
    final emailPrefix = search.toLowerCase();
    var query = _firestore
        .collection('users')
        .where('role', isEqualTo: 'doctor')
        .where('email', isGreaterThanOrEqualTo: emailPrefix)
        .where('email', isLessThan: '$emailPrefix\uf8ff')
        .orderBy('email')
        .orderBy(FieldPath.documentId);
    query = _applyCursor(query, cursor);
    final snapshot = await query.limit(_pageSize + 1).get();
    final users = snapshot.docs.take(_pageSize).toList();
    final mapper = AdminDoctorSnapshotMapper(_firestore);
    final records = <AdminDoctor>[];
    for (final user in users) {
      final profile = await _resolveUserDoctor(user);
      final record = profile == null
          ? await _mapMissingProfile(user)
          : await mapper.map(profile, knownUserData: user.data());
      if (_matchesFilter(record, filter, specialtyId)) records.add(record);
    }

    return AdminDoctorPage(
      doctors: records,
      hasMore: snapshot.docs.length > _pageSize,
      nextCursor: users.isEmpty
          ? cursor
          : AdminDoctorCursor(
              documentId: users.last.id,
              sortField: 'email',
              sortValue: users.last.data()['email'] as String?,
            ),
    );
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> _resolveUserDoctor(
    QueryDocumentSnapshot<Map<String, dynamic>> user,
  ) async {
    final doctorUid = user.id;
    final resolved = await DoctorProfileResolver(_firestore)
        .resolve(uid: doctorUid, userData: user.data());
    return resolved;
  }

  Future<AdminDoctor> _mapMissingProfile(
    QueryDocumentSnapshot<Map<String, dynamic>> user,
  ) async {
    final matches = await _firestore
        .collection('doctors')
        .where('uid', isEqualTo: user.id)
        .limit(2)
        .get();
    final legacy = await _firestore.collection('doctors').doc(user.id).get();
    final ambiguous =
        user.data().containsKey('doctorProfileId') ||
        matches.docs.length > 1 ||
        (matches.docs.length == 1 &&
            legacy.exists &&
            legacy.id != matches.docs.single.id);
    return AdminDoctorModel.missingProfile(
      uid: user.id,
      user: user.data(),
      identityAmbiguous: ambiguous,
    );
  }

  @override
  Future<List<AdminDoctorSpecialty>> getSpecialties() async {
    try {
      final snapshot = await _firestore.collection('specialties').get();
      return snapshot.docs
          .map((document) {
            final name = document.data()['name'];
            return name is String && name.trim().isNotEmpty
                ? AdminDoctorSpecialty(id: document.id, name: name.trim())
                : null;
          })
          .whereType<AdminDoctorSpecialty>()
          .toList()
        ..sort((first, second) => first.name.compareTo(second.name));
    } on FirebaseException catch (error) {
      debugPrint('Admin specialty list failed: ${error.code}');
      throw AdminDoctorException(error.code);
    }
  }

  Query<Map<String, dynamic>> _applyStatus(
    Query<Map<String, dynamic>> query,
    AdminDoctorFilter filter,
  ) => switch (filter) {
    AdminDoctorFilter.all => query,
    AdminDoctorFilter.pending => query.where(
      'approvalStatus',
      isEqualTo: 'pending',
    ),
    AdminDoctorFilter.approved => query.where(
      'approvalStatus',
      isEqualTo: 'approved',
    ),
    AdminDoctorFilter.rejected => query.where(
      'approvalStatus',
      isEqualTo: 'rejected',
    ),
    AdminDoctorFilter.suspended =>
      query
          .where('approvalStatus', isEqualTo: 'approved')
          .where('administrativeStatus', isEqualTo: 'suspended'),
  };

  Query<Map<String, dynamic>> _applyCursor(
    Query<Map<String, dynamic>> query,
    AdminDoctorCursor? cursor,
  ) {
    if (cursor == null) return query;
    if (cursor.sortField != null) {
      return query.startAfter([cursor.sortValue, cursor.documentId]);
    }
    return query.startAfter([cursor.documentId]);
  }

  bool _matchesFilter(
    AdminDoctor doctor,
    AdminDoctorFilter filter,
    String specialtyId,
  ) {
    final statusMatches = switch (filter) {
      AdminDoctorFilter.all => true,
      AdminDoctorFilter.pending =>
        doctor.lifecycle.isValid &&
            doctor.lifecycle.approvalStatus == DoctorApprovalStatus.pending,
      AdminDoctorFilter.approved => doctor.lifecycle.canOperate,
      AdminDoctorFilter.rejected =>
        doctor.lifecycle.isValid &&
            doctor.lifecycle.approvalStatus == DoctorApprovalStatus.rejected,
      AdminDoctorFilter.suspended => doctor.lifecycle.isSuspended,
    };
    return statusMatches &&
        (specialtyId.isEmpty || doctor.specialtyId == specialtyId);
  }
}
