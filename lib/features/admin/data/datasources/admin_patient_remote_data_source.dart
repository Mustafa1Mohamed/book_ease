import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../my_appointments/data/models/my_appointment_model.dart';
import '../../../my_appointments/domain/entities/my_appointment.dart';
import '../../domain/entities/admin_patient.dart';
import '../../domain/entities/admin_patient_appointments_page.dart';
import '../../domain/entities/admin_patient_page.dart';
import '../../domain/errors/admin_patient_exception.dart';
import '../models/admin_patient_model.dart';
import 'admin_patient_data_source.dart';

class AdminPatientRemoteDataSource implements AdminPatientDataSource {
  const AdminPatientRemoteDataSource(this._firestore);

  static const _pageSize = 20;
  final FirebaseFirestore _firestore;

  @override
  Future<AdminPatientPage> getPatients({
    required String search,
    AdminPatientCursor? cursor,
  }) async {
    try {
      final queryText = search.trim();
      final searchField = queryText.isEmpty
          ? null
          : queryText.contains('@')
          ? 'email'
          : 'fullName';
      final normalizedSearch = searchField == 'email'
          ? queryText.toLowerCase()
          : queryText;

      Query<Map<String, dynamic>> query = _firestore
          .collection('users')
          .where('role', isEqualTo: 'patient');
      if (searchField != null) {
        query = query
            .where(searchField, isGreaterThanOrEqualTo: normalizedSearch)
            .where(searchField, isLessThan: '$normalizedSearch\uf8ff')
            .orderBy(searchField)
            .orderBy(FieldPath.documentId);
      } else {
        query = query.orderBy(FieldPath.documentId);
      }

      if (cursor != null) {
        query = cursor.sortField == null
            ? query.startAfter([cursor.documentId])
            : query.startAfter([cursor.sortValue, cursor.documentId]);
      }

      final snapshot = await query.limit(_pageSize + 1).get();
      final documents = snapshot.docs.take(_pageSize).toList(growable: false);
      final hasMore = snapshot.docs.length > _pageSize;
      final last = documents.isEmpty ? null : documents.last;
      final nextCursor = hasMore && last != null
          ? AdminPatientCursor(
              documentId: last.id,
              sortField: searchField,
              sortValue: searchField == null
                  ? null
                  : last.data()[searchField] as String?,
            )
          : null;

      return AdminPatientPage(
        patients: documents
            .map(AdminPatientModel.fromSnapshot)
            .where((patient) => patient.role == 'patient')
            .toList(growable: false),
        hasMore: hasMore,
        nextCursor: nextCursor,
      );
    } on FirebaseException catch (error) {
      debugPrint('Admin patient list failed: ${error.code}');
      throw AdminPatientException(error.code);
    }
  }

  @override
  Future<AdminPatient?> getPatient(String uid) async {
    try {
      final snapshot = await _firestore.collection('users').doc(uid).get();
      if (!snapshot.exists || snapshot.data()?['role'] != 'patient') {
        return null;
      }
      return AdminPatientModel.fromSnapshot(snapshot);
    } on FirebaseException catch (error) {
      debugPrint('Admin patient details failed: ${error.code}');
      throw AdminPatientException(error.code);
    }
  }

  @override
  Future<AdminPatientAppointmentsPage> getAppointments({
    required String patientUid,
    AdminPatientAppointmentCursor? cursor,
  }) async {
    try {
      var query = _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: patientUid)
          .orderBy('appointmentAt', descending: true)
          .orderBy(FieldPath.documentId, descending: true);
      if (cursor != null) {
        query = query.startAfter([
          Timestamp.fromDate(cursor.appointmentAt),
          cursor.documentId,
        ]);
      }

      final snapshot = await query.limit(_pageSize + 1).get();
      final documents = snapshot.docs.take(_pageSize).toList(growable: false);
      final hasMore = snapshot.docs.length > _pageSize;
      final last = documents.isEmpty ? null : documents.last;
      final lastDate = last == null ? null : _appointmentDate(last.data());
      final nextCursor = hasMore && last != null && lastDate != null
          ? AdminPatientAppointmentCursor(
              documentId: last.id,
              appointmentAt: lastDate,
            )
          : null;
      final appointments = documents
          .map(
            (document) =>
                MyAppointmentModel.fromMap(document.id, document.data()),
          )
          .whereType<MyAppointment>()
          .toList(growable: false);
      return AdminPatientAppointmentsPage(
        appointments: appointments,
        hasMore: hasMore && nextCursor != null,
        nextCursor: nextCursor,
      );
    } on FirebaseException catch (error) {
      debugPrint('Admin patient appointments failed: ${error.code}');
      throw AdminPatientException(error.code);
    }
  }

  DateTime? _appointmentDate(Map<String, dynamic> data) =>
      switch (data['appointmentAt']) {
        Timestamp timestamp => timestamp.toDate(),
        DateTime dateTime => dateTime,
        _ => null,
      };
}
