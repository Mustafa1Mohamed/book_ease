import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../my_appointments/data/models/my_appointment_model.dart';
import '../../../my_appointments/domain/entities/my_appointment.dart';
import '../../domain/entities/admin_doctor.dart';
import '../../domain/entities/admin_doctor_details.dart';
import '../../domain/errors/admin_doctor_exception.dart';
import '../models/admin_doctor_audit_model.dart';
import '../models/admin_doctor_model.dart';
import '../models/admin_doctor_snapshot_mapper.dart';
import 'admin_doctor_details_data_source.dart';

class AdminDoctorDetailsRemoteDataSource
    implements AdminDoctorDetailsDataSource {
  const AdminDoctorDetailsRemoteDataSource(this._firestore);

  static const _pageSize = 20;
  static const _upcomingStatuses = [
    'confirmed',
    'pending',
    'scheduled',
    'booked',
  ];

  final FirebaseFirestore _firestore;

  @override
  Future<AdminDoctorDetails> getDoctorDetails(String doctorId) async {
    try {
      final doctorSnapshot = await _firestore
          .collection('doctors')
          .doc(doctorId)
          .get();
      if (!doctorSnapshot.exists) {
        final user = await _firestore.collection('users').doc(doctorId).get();
        final userData = user.data();
        if (!user.exists || userData?['role'] != 'doctor') {
          throw const AdminDoctorException('not-found');
        }
        return AdminDoctorDetails(
          doctor: AdminDoctorModel.missingProfile(
            uid: doctorId,
            user: userData!,
            identityAmbiguous: userData.containsKey('doctorProfileId'),
          ),
          upcomingAppointments: const [],
          upcomingAppointmentsUnavailable: true,
        );
      }

      final doctor = await AdminDoctorSnapshotMapper(_firestore)
          .map(doctorSnapshot);
      var appointmentsUnavailable = false;
      List<MyAppointment> appointments;
      if (!doctor.identityVerified) {
        appointments = const [];
        appointmentsUnavailable = true;
      } else {
        try {
          appointments = await _loadUpcomingAppointments(doctor);
        } on FirebaseException catch (error) {
          debugPrint('Admin doctor appointments failed: ${error.code}');
          appointments = const [];
          appointmentsUnavailable = true;
        }
      }
      return AdminDoctorDetails(
        doctor: doctor,
        upcomingAppointments: appointments,
        upcomingAppointmentsUnavailable: appointmentsUnavailable,
      );
    } on FirebaseException catch (error) {
      debugPrint('Admin doctor details failed: ${error.code}');
      throw AdminDoctorException(error.code);
    }
  }

  Future<List<MyAppointment>> _loadUpcomingAppointments(
    AdminDoctor doctor,
  ) async {
    final doctorIds = {doctor.id, doctor.uid};
    final queries = doctorIds.map((id) {
      return _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: id)
          .where('status', whereIn: _upcomingStatuses)
          .where('appointmentAt', isGreaterThanOrEqualTo: Timestamp.now())
          .orderBy('appointmentAt')
          .limit(10)
          .get();
    });
    final snapshots = await Future.wait(queries);
    final documents = {
      for (final snapshot in snapshots)
        for (final document in snapshot.docs) document.id: document,
    }.values;
    return documents
        .map(
          (document) =>
              MyAppointmentModel.fromMap(document.id, document.data()),
        )
        .whereType<MyAppointment>()
        .toList()
      ..sort(
        (first, second) => first.scheduledAt.compareTo(second.scheduledAt),
      );
  }

  @override
  Future<AdminDoctorAuditPage> getAuditHistory({
    required String targetDoctorUid,
    AdminDoctorAuditCursor? cursor,
  }) async {
    if (targetDoctorUid.isEmpty) {
      return const AdminDoctorAuditPage(events: [], hasMore: false);
    }
    try {
      var query = _firestore
          .collection('doctor_admin_audit')
          .where('targetDoctorUid', isEqualTo: targetDoctorUid)
          .orderBy('createdAt', descending: true)
          .orderBy(FieldPath.documentId, descending: true);
      if (cursor != null) {
        query = query.startAfter([
          Timestamp.fromDate(cursor.createdAt),
          cursor.documentId,
        ]);
      }

      final snapshot = await query.limit(_pageSize + 1).get();
      final documents = snapshot.docs.take(_pageSize).toList();
      final events = documents
          .map(AdminDoctorAuditModel.fromSnapshot)
          .toList(growable: false);
      final last = documents.isEmpty ? null : documents.last;
      final createdAt = last == null
          ? null
          : AdminDoctorModel.timestamp(last.data()['createdAt']);
      return AdminDoctorAuditPage(
        events: events,
        hasMore: snapshot.docs.length > _pageSize,
        nextCursor: last == null || createdAt == null
            ? null
            : AdminDoctorAuditCursor(documentId: last.id, createdAt: createdAt),
      );
    } on FirebaseException catch (error) {
      debugPrint('Admin doctor audit history failed: ${error.code}');
      throw AdminDoctorException(error.code);
    }
  }
}
