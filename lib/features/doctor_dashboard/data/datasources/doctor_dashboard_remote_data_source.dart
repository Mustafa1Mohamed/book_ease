import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/firebase/doctor_profile_resolver.dart';
import '../../../auth/domain/entities/doctor_lifecycle_status.dart';
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
      final doctorSnapshot = await _requireApprovedDoctor(uid);
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

      final appointments = await _loadAppointments(doctor.id);
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

  Future<List<MyAppointment>> _loadAppointments(String doctorId) async {
    final collection = _firestore.collection('appointments');
    final snapshot = await collection
        .where('doctorId', isEqualTo: doctorId)
        .get();
    final appointments =
        snapshot.docs
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
      final doctor = await _requireApprovedDoctor(uid);
      final snapshot = await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .get();
      final data = snapshot.data();
      if (data == null || data['doctorId'] != doctor.id) {
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
      final doctor = await _requireApprovedDoctor(uid);
      final userRef = _firestore.collection('users').doc(uid);
      final doctorRef = _firestore.collection('doctors').doc(doctor.id);
      final appointmentRef = _firestore
          .collection('appointments')
          .doc(appointmentId);

      await _firestore.runTransaction<void>((transaction) async {
        final userSnapshot = await transaction.get(userRef);
        final doctorSnapshot = await transaction.get(doctorRef);
        final appointmentSnapshot = await transaction.get(appointmentRef);
        final userData = userSnapshot.data();
        final doctorData = doctorSnapshot.data();
        final data = appointmentSnapshot.data();
        if (userData == null ||
            doctorData == null ||
            !DoctorProfileResolver.isLinkedProfile(
              uid: uid,
              doctorId: doctor.id,
              userData: userData,
              doctorData: doctorData,
            ) ||
            !DoctorLifecycleStatus.fromDoctorData(doctorData).canOperate ||
            data == null ||
            data['doctorId'] != doctor.id) {
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

  Future<DocumentSnapshot<Map<String, dynamic>>> _requireApprovedDoctor(
    String uid,
  ) async {
    final user = await _firestore.collection('users').doc(uid).get();
    final userData = user.data();
    if (userData?['role'] != 'doctor') {
      throw const DoctorDashboardException(
        'This dashboard is only available to doctor accounts.',
      );
    }
    final doctor = await _resolveDoctor(uid, userData);
    final lifecycle = DoctorLifecycleStatus.fromDoctorData(doctor.data());
    if (!lifecycle.canOperate) {
      throw const DoctorDashboardException(
        'This doctor account is not active and approved to access the dashboard.',
      );
    }
    return doctor;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _resolveDoctor(
    String uid,
    Map<String, dynamic>? userData,
  ) async {
    final doctor = await DoctorProfileResolver(_firestore)
        .resolve(uid: uid, userData: userData);
    if (doctor == null) {
      throw const DoctorDashboardException(
        'A unique doctor profile is not linked to this account.',
      );
    }
    return doctor;
  }
}
