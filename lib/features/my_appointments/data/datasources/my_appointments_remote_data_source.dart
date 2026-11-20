import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/my_appointment.dart';
import '../../domain/errors/my_appointments_exception.dart';
import '../../domain/services/appointment_cancellation_policy.dart';
import '../models/my_appointment_model.dart';

class MyAppointmentsRemoteDataSource {
  const MyAppointmentsRemoteDataSource(
    this._firestore,
    this._firebaseAuth,
    this._cancellationPolicy,
  );

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;
  final AppointmentCancellationPolicy _cancellationPolicy;

  Future<List<MyAppointment>> getMyAppointments() async {
    final uid = _currentPatientId();
    try {
      final snapshot = await _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: uid)
          .get();
      final appointments = snapshot.docs
          .map(
            (document) =>
                MyAppointmentModel.fromMap(document.id, document.data()),
          )
          .whereType<MyAppointment>()
          .toList();
      return await _enrichDoctorData(appointments);
    } on FirebaseException catch (error) {
      debugPrint('Appointments query failed: ${error.code}');
      throw const MyAppointmentsException(
        'Appointments could not be loaded. Please try again.',
      );
    }
  }

  Future<MyAppointment?> getMyAppointment(String appointmentId) async {
    final uid = _currentPatientId();
    if (appointmentId.trim().isEmpty) return null;
    try {
      final snapshot = await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .get();
      final data = snapshot.data();
      if (data == null || data['patientId'] != uid) return null;
      final appointment = MyAppointmentModel.fromMap(snapshot.id, data);
      if (appointment == null) return null;
      final enriched = await _enrichDoctorData([appointment]);
      return enriched.first;
    } on FirebaseException catch (error) {
      debugPrint('Appointment detail query failed: ${error.code}');
      throw const MyAppointmentsException(
        'Appointment details could not be loaded. Please try again.',
      );
    }
  }

  Future<void> cancelAppointment(String appointmentId) async {
    final uid = _currentPatientId();
    if (appointmentId.trim().isEmpty) {
      throw const MyAppointmentsException('Appointment was not found.');
    }

    final appointmentRef = _firestore
        .collection('appointments')
        .doc(appointmentId);
    try {
      await _firestore.runTransaction<void>((transaction) async {
        final appointmentSnapshot = await transaction.get(appointmentRef);
        final data = appointmentSnapshot.data();
        if (data == null || data['patientId'] != uid) {
          throw const MyAppointmentsException('Appointment was not found.');
        }
        final appointment = MyAppointmentModel.fromMap(
          appointmentSnapshot.id,
          data,
        );
        if (appointment == null ||
            !_cancellationPolicy.canCancel(appointment, DateTime.now())) {
          throw const MyAppointmentsException(
            'This appointment can no longer be cancelled.',
          );
        }

        DocumentReference<Map<String, dynamic>>? slotRef;
        DocumentSnapshot<Map<String, dynamic>>? slotSnapshot;
        if (appointment.doctorId.isNotEmpty && appointment.slotId.isNotEmpty) {
          slotRef = _firestore
              .collection('doctors')
              .doc(appointment.doctorId)
              .collection('availabilitySlots')
              .doc(appointment.slotId);
          slotSnapshot = await transaction.get(slotRef);
        }

        transaction.update(appointmentRef, {
          'status': 'cancelled',
          'cancelledAt': FieldValue.serverTimestamp(),
        });
        if (slotRef != null &&
            slotSnapshot?.data()?['appointmentId'] == appointmentId) {
          transaction.update(slotRef, {
            'isAvailable': true,
            'appointmentId': FieldValue.delete(),
            'reservedAt': FieldValue.delete(),
          });
        }
      });
    } on MyAppointmentsException {
      rethrow;
    } on FirebaseException catch (error) {
      debugPrint('Appointment cancellation failed: ${error.code}');
      throw MyAppointmentsException(
        error.code == 'permission-denied'
            ? 'Cancellation was not authorized. Refresh and try again.'
            : 'Appointment could not be cancelled. Please try again.',
      );
    }
  }

  String _currentPatientId() {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const MyAppointmentsException('Sign in to view your appointments.');
    }
    return user.uid;
  }

  Future<List<MyAppointment>> _enrichDoctorData(
    List<MyAppointment> appointments,
  ) async {
    final doctorIds = appointments
        .where(
          (appointment) =>
              appointment.doctorId.isNotEmpty &&
              (appointment.clinicName.isEmpty ||
                  appointment.clinicAddress.isEmpty ||
                  appointment.consultationType.isEmpty ||
                  appointment.specialtyName.isEmpty),
        )
        .map((appointment) => appointment.doctorId)
        .toSet();
    if (doctorIds.isEmpty) return appointments;

    final doctorResults = await Future.wait(
      doctorIds.map((id) => _loadDoctorRecord(id)),
    );
    final doctorRecords = <String, _DoctorRecord>{
      for (final record in doctorResults.whereType<_DoctorRecord>())
        record.lookupId: record,
    };
    final specialtyIds = doctorRecords.values
        .map((record) => _string(record.data['specialtyId']))
        .where((id) => id.isNotEmpty)
        .toSet();
    final specialtyNames = await _loadSpecialtyNames(specialtyIds);

    return appointments.map((appointment) {
      final record = doctorRecords[appointment.doctorId];
      if (record == null) return appointment;
      return MyAppointmentModel.withDoctorDetails(
        appointment,
        record.documentId,
        record.data,
        specialtyNamesById: specialtyNames,
      );
    }).toList();
  }

  Future<_DoctorRecord?> _loadDoctorRecord(String doctorId) async {
    final doctors = _firestore.collection('doctors');
    try {
      final direct = await doctors.doc(doctorId).get();
      if (direct.data() case final data?) {
        return _DoctorRecord(doctorId, direct.id, data);
      }
      final byUid = await doctors
          .where('uid', isEqualTo: doctorId)
          .limit(1)
          .get();
      if (byUid.docs.isEmpty) return null;
      final document = byUid.docs.first;
      return _DoctorRecord(doctorId, document.id, document.data());
    } on FirebaseException catch (error) {
      debugPrint('Optional doctor details unavailable: ${error.code}');
      return null;
    }
  }

  Future<Map<String, String>> _loadSpecialtyNames(Set<String> ids) async {
    final results = await Future.wait(
      ids.map((id) async {
        try {
          final document = await _firestore
              .collection('specialties')
              .doc(id)
              .get();
          return MapEntry(id, _string(document.data()?['name']));
        } on FirebaseException catch (error) {
          debugPrint('Optional specialty details unavailable: ${error.code}');
          return MapEntry(id, '');
        }
      }),
    );
    return {
      for (final result in results)
        if (result.value.isNotEmpty) result.key: result.value,
    };
  }

  String _string(Object? value) => value is String ? value.trim() : '';
}

class _DoctorRecord {
  const _DoctorRecord(this.lookupId, this.documentId, this.data);

  final String lookupId;
  final String documentId;
  final Map<String, dynamic> data;
}
