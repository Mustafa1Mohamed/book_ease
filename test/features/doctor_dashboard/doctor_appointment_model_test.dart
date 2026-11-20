import 'package:book_ease/features/my_appointments/data/models/my_appointment_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'reads patient booking snapshots from the existing appointment record',
    () {
      final appointment = MyAppointmentModel.fromMap('appointment-1', {
        'patientId': 'patient-1',
        'patientName': 'Alex Patient',
        'patientImageUrl': 'https://example.test/patient.png',
        'patientPhoneNumber': '555-1234',
        'doctorId': 'doctor-1',
        'appointmentAt': DateTime(2030, 7, 18, 9),
        'status': 'confirmed',
      });

      if (appointment == null) fail('Expected appointment to be parsed.');
      expect(appointment.patientName, 'Alex Patient');
      expect(appointment.patientImageUrl, 'https://example.test/patient.png');
      expect(appointment.patientPhoneNumber, '555-1234');
    },
  );

  test('keeps patient details optional for historical appointments', () {
    final appointment = MyAppointmentModel.fromMap('legacy-appointment', {
      'patientId': 'patient-1',
      'doctorId': 'doctor-1',
      'appointmentAt': DateTime(2030, 7, 18, 9),
      'status': 'confirmed',
    });

    if (appointment == null) fail('Expected appointment to be parsed.');
    expect(appointment.patientName, isEmpty);
    expect(appointment.patientImageUrl, isEmpty);
    expect(appointment.patientPhoneNumber, isEmpty);
  });
}
