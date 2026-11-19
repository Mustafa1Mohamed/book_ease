import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/appointment_slot.dart';
import '../../domain/entities/booking_confirmation.dart';
import '../../domain/errors/booking_exception.dart';

class BookingRemoteDataSource {
  const BookingRemoteDataSource(this._firestore, this._firebaseAuth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  Future<List<DateTime>> getAvailableDates(String doctorId) async {
    try {
      final snapshot = await _firestore
          .collection('doctors')
          .doc(doctorId)
          .collection('availabilitySlots')
          .where('startAt', isGreaterThanOrEqualTo: Timestamp.now())
          .orderBy('startAt')
          .get();
      final dates = <DateTime>{};
      for (final document in snapshot.docs) {
        final slot = _slotFromMap(document.id, document.data());
        if (slot == null || !slot.startAt.isAfter(DateTime.now())) continue;
        final local = slot.startAt.toLocal();
        dates.add(DateTime(local.year, local.month, local.day));
      }
      final result = dates.toList()..sort();
      return result;
    } on FirebaseException {
      throw const BookingException(
        'Available dates could not be loaded. Please try again.',
      );
    }
  }

  Future<List<AppointmentSlot>> getAvailableSlots(
    String doctorId,
    DateTime date,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final startOfNextDay = startOfDay.add(const Duration(days: 1));
    try {
      final snapshot = await _firestore
          .collection('doctors')
          .doc(doctorId)
          .collection('availabilitySlots')
          .where(
            'startAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where(
            'startAt',
            isLessThan: Timestamp.fromDate(startOfNextDay),
          )
          .orderBy('startAt')
          .get();
      final now = DateTime.now();
      return snapshot.docs
          .map((document) => _slotFromMap(document.id, document.data()))
          .whereType<AppointmentSlot>()
          .where((slot) => slot.startAt.isAfter(now))
          .toList();
    } on FirebaseException {
      throw const BookingException(
        'Appointment times could not be loaded. Please try again.',
      );
    }
  }

  Future<BookingConfirmation> bookAppointment({
    required String doctorId,
    required String slotId,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const BookingException('Sign in before booking an appointment.');
    }
    if (doctorId.trim().isEmpty || slotId.trim().isEmpty) {
      throw const BookingException('Choose a valid appointment time.');
    }

    final patientRef = _firestore.collection('users').doc(user.uid);
    final doctorRef = _firestore.collection('doctors').doc(doctorId);
    final slotRef = doctorRef.collection('availabilitySlots').doc(slotId);
    final appointmentRef = _firestore.collection('appointments').doc();

    try {
      return await _firestore.runTransaction<BookingConfirmation>((
        transaction,
      ) async {
        final patientSnapshot = await transaction.get(patientRef);
        final doctorSnapshot = await transaction.get(doctorRef);
        final slotSnapshot = await transaction.get(slotRef);
        final patient = patientSnapshot.data();
        final doctor = doctorSnapshot.data();
        final slotData = slotSnapshot.data();

        if (!patientSnapshot.exists || patient?['role'] != 'patient') {
          throw const BookingException(
            'Only patient accounts can book appointments.',
          );
        }
        if (!doctorSnapshot.exists || doctor == null) {
          throw const BookingException('This doctor is no longer available.');
        }
        if (!slotSnapshot.exists || slotData == null) {
          throw const BookingException(
            'This appointment time is no longer available.',
          );
        }

        final slot = _slotFromMap(slotSnapshot.id, slotData);
        if (slot == null ||
            slotData['isAvailable'] != true ||
            !slot.startAt.isAfter(DateTime.now())) {
          throw const BookingException(
            'This appointment time is no longer available. Choose another time.',
          );
        }

        final doctorName = _string(doctor['fullName']).trim().isNotEmpty
            ? _string(doctor['fullName']).trim()
            : _string(doctor['name']).trim();
        if (doctorName.isEmpty) {
          throw const BookingException(
            'This doctor cannot accept appointments right now.',
          );
        }

        final specialtyId = _string(doctor['specialtyId']);
        final specialtyName = _string(doctor['specialtyName']);
        final consultationFee = _number(doctor['consultationFee']) ?? 0;
        final appointmentAt = Timestamp.fromDate(slot.startAt);
        final appointmentTime = DateFormat.jm().format(slot.startAt.toLocal());

        transaction.update(slotRef, {
          'isAvailable': false,
          'appointmentId': appointmentRef.id,
          'reservedAt': FieldValue.serverTimestamp(),
        });
        transaction.set(appointmentRef, {
          'patientId': user.uid,
          'doctorId': doctorId,
          'doctorName': doctorName,
          'doctorImageUrl': _string(doctor['profileImageUrl']),
          'specialtyId': specialtyId,
          'specialtyName': specialtyName,
          'slotId': slot.id,
          'appointmentAt': appointmentAt,
          'appointmentEndAt': Timestamp.fromDate(slot.endAt),
          'appointmentDate': appointmentAt,
          'appointmentTime': appointmentTime,
          'consultationFee': consultationFee,
          'status': 'confirmed',
          'createdAt': FieldValue.serverTimestamp(),
        });
        return BookingConfirmation(
          appointmentId: appointmentRef.id,
          doctorName: doctorName,
          startAt: slot.startAt,
          endAt: slot.endAt,
        );
      });
    } on BookingException {
      rethrow;
    } on FirebaseException catch (error) {
      if (error.code == 'permission-denied') {
        throw const BookingException(
          'Booking was not authorized. Refresh availability and try again.',
        );
      }
      throw const BookingException(
        'Your appointment could not be booked. Please try again.',
      );
    }
  }

  AppointmentSlot? _slotFromMap(String id, Map<String, dynamic> data) {
    final startAt = _dateTime(data['startAt']);
    final endAt = _dateTime(data['endAt']);
    if (startAt == null ||
        endAt == null ||
        !endAt.isAfter(startAt) ||
        data['isAvailable'] != true) {
      return null;
    }
    return AppointmentSlot(id: id, startAt: startAt, endAt: endAt);
  }

  DateTime? _dateTime(Object? value) => switch (value) {
    Timestamp value => value.toDate(),
    DateTime value => value,
    _ => null,
  };

  String _string(Object? value) => value is String ? value : '';

  double? _number(Object? value) {
    final number = switch (value) {
      num value => value.toDouble(),
      _ => null,
    };
    return number != null && number.isFinite && number >= 0 ? number : null;
  }
}
