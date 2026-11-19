import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:book_ease/features/home/data/models/upcoming_appointment_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('combines appointment date with a 12-hour time label', () {
    final appointment = UpcomingAppointmentModel.fromMap('appointment-1', {
      'appointmentDate': DateTime(2030, 6, 12),
      'appointmentTime': '3:45 PM',
      'status': 'confirmed',
    });

    if (appointment == null) fail('Expected appointment to be parsed.');
    expect(appointment.scheduledAt, DateTime(2030, 6, 12, 15, 45));
    expect(
      UpcomingAppointmentModel.isUpcoming(
        appointment,
        DateTime(2030, 6, 12, 14),
      ),
      isTrue,
    );
  });

  test('does not treat completed or cancelled appointments as upcoming', () {
    final appointment = UpcomingAppointmentModel.fromMap('appointment-2', {
      'appointmentDate': DateTime(2030, 6, 12, 15),
      'status': 'completed',
    });

    if (appointment == null) fail('Expected appointment to be parsed.');
    expect(
      UpcomingAppointmentModel.isUpcoming(
        appointment,
        DateTime(2030, 6, 12, 14),
      ),
      isFalse,
    );
  });

  test('prefers the canonical appointment timestamp over legacy date fields', () {
    final canonicalDate = DateTime(2030, 6, 12, 16, 20);
    final appointment = UpcomingAppointmentModel.fromMap('appointment-3', {
      'appointmentAt': Timestamp.fromDate(canonicalDate),
      'appointmentDate': DateTime(2030, 6, 13),
      'appointmentTime': '9:00 AM',
    });

    if (appointment == null) fail('Expected appointment to be parsed.');
    expect(appointment.scheduledAt, canonicalDate);
  });
}
