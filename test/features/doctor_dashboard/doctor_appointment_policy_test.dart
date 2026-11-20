import 'package:book_ease/features/doctor_dashboard/domain/entities/doctor_appointment_filter.dart';
import 'package:book_ease/features/doctor_dashboard/domain/services/doctor_appointment_policy.dart';
import 'package:book_ease/features/my_appointments/domain/entities/my_appointment.dart';
import 'package:flutter_test/flutter_test.dart';

MyAppointment _appointment({
  required String status,
  required DateTime start,
  DateTime? end,
}) {
  return MyAppointment(
    id: 'appointment-1',
    patientId: 'patient-1',
    doctorId: 'doctor-1',
    doctorName: 'Dr. Morgan Lee',
    doctorImageUrl: '',
    specialtyId: 'cardiology',
    specialtyName: 'Cardiology',
    scheduledAt: start,
    endAt: end,
    status: status,
  );
}

void main() {
  const policy = DoctorAppointmentPolicy();

  test('only permits completing a confirmed appointment after it ends', () {
    final now = DateTime(2030, 7, 18, 12);

    expect(
      policy.canComplete(
        _appointment(
          status: 'confirmed',
          start: now.subtract(const Duration(hours: 1)),
          end: now,
        ),
        now,
      ),
      isTrue,
    );
    expect(
      policy.canComplete(
        _appointment(
          status: 'confirmed',
          start: now.add(const Duration(hours: 1)),
          end: now.add(const Duration(hours: 2)),
        ),
        now,
      ),
      isFalse,
    );
    expect(
      policy.canComplete(
        _appointment(
          status: 'cancelled',
          start: now.subtract(const Duration(hours: 1)),
          end: now.subtract(const Duration(minutes: 30)),
        ),
        now,
      ),
      isFalse,
    );
  });

  test('filters appointment statuses without conflating cancelled records', () {
    expect(DoctorAppointmentFilter.confirmed.matches('confirmed'), isTrue);
    expect(DoctorAppointmentFilter.confirmed.matches('booked'), isTrue);
    expect(DoctorAppointmentFilter.cancelled.matches('rejected'), isTrue);
    expect(DoctorAppointmentFilter.cancelled.matches('completed'), isFalse);
    expect(DoctorAppointmentFilter.pending.matches('confirmed'), isFalse);
  });
}
