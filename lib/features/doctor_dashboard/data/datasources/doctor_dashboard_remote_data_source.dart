import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../home/data/models/featured_doctor_model.dart';
import '../../../my_appointments/data/models/my_appointment_model.dart';
import '../../../my_appointments/domain/entities/my_appointment.dart';
import '../../domain/entities/doctor_dashboard_data.dart';
import '../../domain/errors/doctor_dashboard_exception.dart';
import '../../domain/services/doctor_appointment_policy.dart';

class DoctorDashboardRemoteDataSource {
  const DoctorDashboardRemoteDataSource(
    this._firestore,
    this._firebaseAuth,
    this._appointmentPolicy,
  );

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;
  final DoctorAppointmentPolicy _appointmentPolicy;

  Future<DoctorDashboardData> getDashboard() async {
    final uid = _currentUid();
    try {
      await _requireDoctorRole(uid);
      final doctorSnapshot = await _resolveDoctor(uid);
      final doctorData = doctorSnapshot.data();
      if (doctorData == null) {
        throw const DoctorDashboardException(
          'A doctor profile is not linked to this account.',
        );
      }
      final doctor = FeaturedDoctorModel.fromMap(
        doctorSnapshot.id,
        doctorData,
        specialtyNamesById: const {},
      );
      if (doctor == null) {
        throw const DoctorDashboardException(
          'The doctor profile is missing required information.',
        );
      }

      final appointments = await _loadAppointments(doctor.id, uid);
      return DoctorDashboardData(doctor: doctor, appointments: appointments);
    } on DoctorDashboardException {
      rethrow;
    } on FirebaseException catch (error) {
      debugPrint('Doctor dashboard load failed: ${error.code}');
      throw const DoctorDashboardException(
        'Dashboard data could not be loaded. Please try again.',
      );
    }
  }

  Future<List<MyAppointment>> _loadAppointments(
    String doctorId,
    String uid,
  ) async {
    final collection = _firestore.collection('appointments');
    final queries = <Future<QuerySnapshot<Map<String, dynamic>>>>[
      collection.where('doctorId', isEqualTo: doctorId).get(),
      if (doctorId != uid) collection.where('doctorId', isEqualTo: uid).get(),
    ];
    final snapshots = await Future.wait(queries);
    final documents = {
      for (final snapshot in snapshots)
        for (final document in snapshot.docs) document.id: document,
    }.values;
    final appointments =
        documents
            .map(
              (document) =>
                  MyAppointmentModel.fromMap(document.id, document.data()),
            )
            .whereType<MyAppointment>()
            .toList()
          ..sort(
            (first, second) => first.scheduledAt.compareTo(second.scheduledAt),
          );
    return appointments;
  }

  Future<MyAppointment?> getAppointment(String appointmentId) async {
    if (appointmentId.trim().isEmpty) return null;
    final uid = _currentUid();
    try {
      await _requireDoctorRole(uid);
      final doctor = await _resolveDoctor(uid);
      final snapshot = await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .get();
      final data = snapshot.data();
      if (data == null ||
          (data['doctorId'] != doctor.id && data['doctorId'] != uid)) {
        return null;
      }
      return MyAppointmentModel.fromMap(snapshot.id, data);
    } on DoctorDashboardException {
      rethrow;
    } on FirebaseException catch (error) {
      debugPrint('Doctor appointment load failed: ${error.code}');
      throw const DoctorDashboardException(
        'Appointment details could not be loaded. Please retry.',
      );
    }
  }

  Future<void> completeAppointment(String appointmentId) async {
    final uid = _currentUid();
    if (appointmentId.trim().isEmpty) {
      throw const DoctorDashboardException('Appointment was not found.');
    }
    try {
      await _requireDoctorRole(uid);
      final doctor = await _resolveDoctor(uid);
      final userRef = _firestore.collection('users').doc(uid);
      final doctorRef = _firestore.collection('doctors').doc(doctor.id);
      final appointmentRef = _firestore
          .collection('appointments')
          .doc(appointmentId);

      await _firestore.runTransaction<void>((transaction) async {
        final userSnapshot = await transaction.get(userRef);
        final doctorSnapshot = await transaction.get(doctorRef);
        final appointmentSnapshot = await transaction.get(appointmentRef);
        final data = appointmentSnapshot.data();
        if (userSnapshot.data()?['role'] != 'doctor' ||
            !_ownsDoctorProfile(doctorSnapshot, uid) ||
            data == null ||
            (data['doctorId'] != doctor.id && data['doctorId'] != uid)) {
          throw const DoctorDashboardException('Appointment was not found.');
        }
        final appointment = MyAppointmentModel.fromMap(
          appointmentSnapshot.id,
          data,
        );
        if (appointment == null ||
            !_appointmentPolicy.canComplete(appointment, DateTime.now())) {
          throw const DoctorDashboardException(
            'Only confirmed appointments that have ended can be completed.',
          );
        }
        transaction.update(appointmentRef, {
          'status': 'completed',
          'completedAt': FieldValue.serverTimestamp(),
        });
      });
    } on DoctorDashboardException {
      rethrow;
    } on FirebaseException catch (error) {
      debugPrint('Appointment completion failed: ${error.code}');
      throw DoctorDashboardException(
        error.code == 'permission-denied'
            ? 'This appointment cannot be updated by your account.'
            : 'Appointment could not be marked complete. Please retry.',
      );
    }
  }

  String _currentUid() {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const DoctorDashboardException('Sign in to open the dashboard.');
    }
    return user.uid;
  }

  Future<void> _requireDoctorRole(String uid) async {
    final user = await _firestore.collection('users').doc(uid).get();
    if (user.data()?['role'] != 'doctor') {
      throw const DoctorDashboardException(
        'This dashboard is only available to doctor accounts.',
      );
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _resolveDoctor(
    String uid,
  ) async {
    final matches = await _firestore
        .collection('doctors')
        .where('uid', isEqualTo: uid)
        .limit(2)
        .get();
    if (matches.docs.length > 1) {
      throw const DoctorDashboardException(
        'More than one doctor profile is linked to this account.',
      );
    }
    if (matches.docs case [final doctor]) return doctor;

    final direct = await _firestore.collection('doctors').doc(uid).get();
    if (_ownsDoctorProfile(direct, uid)) return direct;
    throw const DoctorDashboardException(
      'A doctor profile is not linked to this account.',
    );
  }

  bool _ownsDoctorProfile(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    String uid,
  ) {
    final data = snapshot.data();
    if (data == null) return false;
    final ownerUid = _string(data['uid']);
    return ownerUid.isEmpty ? snapshot.id == uid : ownerUid == uid;
  }

  String _string(Object? value) => value is String ? value.trim() : '';
}
