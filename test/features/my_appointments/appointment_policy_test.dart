import 'package:book_ease/features/my_appointments/domain/entities/appointment_category.dart';
import 'package:book_ease/features/my_appointments/domain/entities/my_appointment.dart';
import 'package:book_ease/features/my_appointments/domain/services/appointment_cancellation_policy.dart';
import 'package:book_ease/features/my_appointments/domain/services/appointment_category_policy.dart';
import 'package:book_ease/features/my_appointments/presentation/cubit/my_appointments_state.dart';
import 'package:flutter_test/flutter_test.dart';

MyAppointment _appointment({
  required String id,
  required DateTime date,
  String status = 'confirmed',
}) {
  return MyAppointment(
    id: id,
    patientId: 'patient-1',
    doctorId: 'doctor-1',
    doctorName: 'Dr. Morgan Lee',
    doctorImageUrl: '',
    specialtyId: 'cardiology',
    specialtyName: 'Cardiology',
    scheduledAt: date,
    status: status,
  );
}

void main() {
  const categoryPolicy = AppointmentCategoryPolicy();

  test('classifies appointments into upcoming, completed, and cancelled', () {
    final now = DateTime(2030, 7, 18, 8);
    final appointments = [
      _appointment(id: 'future', date: now.add(const Duration(hours: 2))),
      _appointment(id: 'past', date: now.subtract(const Duration(hours: 2))),
      _appointment(
        id: 'cancelled',
        date: now.add(const Duration(days: 1)),
        status: 'cancelled',
      ),
    ];

    expect(
      appointments
          .map((item) => categoryPolicy.categoryOf(item, now))
          .toList(),
      [
        AppointmentCategory.upcoming,
        AppointmentCategory.completed,
        AppointmentCategory.cancelled,
      ],
    );
  });

  test('sorts upcoming chronologically and past categories newest first', () {
    final now = DateTime(2030, 7, 18, 8);
    final loaded = MyAppointmentsLoaded(
      appointments: [
        _appointment(id: 'later', date: now.add(const Duration(hours: 4))),
        _appointment(id: 'earlier', date: now.add(const Duration(hours: 1))),
        _appointment(
          id: 'old',
          date: now.subtract(const Duration(days: 3)),
          status: 'completed',
        ),
        _appointment(
          id: 'recent',
          date: now.subtract(const Duration(days: 1)),
          status: 'completed',
        ),
      ],
    );

    expect(
      loaded
          .appointmentsFor(
            AppointmentCategory.upcoming,
            now,
            categoryPolicy,
          )
          .map((item) => item.id),
      ['earlier', 'later'],
    );
    expect(
      loaded
          .appointmentsFor(
            AppointmentCategory.completed,
            now,
            categoryPolicy,
          )
          .map((item) => item.id),
      ['recent', 'old'],
    );
  });

  test('cancellation is limited to eligible future appointment statuses', () {
    final now = DateTime(2030, 7, 18, 8);
    final policy = AppointmentCancellationPolicy();

    expect(
      policy.canCancel(
        _appointment(id: 'upcoming', date: now.add(const Duration(hours: 1))),
        now,
      ),
      isTrue,
    );
    expect(
      policy.canCancel(
        _appointment(
          id: 'completed',
          date: now.add(const Duration(hours: 1)),
          status: 'completed',
        ),
        now,
      ),
      isFalse,
    );
    expect(
      policy.canCancel(
        _appointment(id: 'started', date: now.subtract(const Duration(minutes: 1))),
        now,
      ),
      isFalse,
    );
  });
}
