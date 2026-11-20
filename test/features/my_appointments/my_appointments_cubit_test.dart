import 'package:book_ease/features/my_appointments/domain/entities/my_appointment.dart';
import 'package:book_ease/features/my_appointments/domain/errors/my_appointments_exception.dart';
import 'package:book_ease/features/my_appointments/domain/repositories/my_appointments_repository.dart';
import 'package:book_ease/features/my_appointments/domain/services/appointment_category_policy.dart';
import 'package:book_ease/features/my_appointments/domain/services/appointment_cancellation_policy.dart';
import 'package:book_ease/features/my_appointments/domain/usecases/cancel_appointment.dart';
import 'package:book_ease/features/my_appointments/domain/usecases/get_my_appointment.dart';
import 'package:book_ease/features/my_appointments/domain/usecases/get_my_appointments.dart';
import 'package:book_ease/features/my_appointments/presentation/cubit/appointment_details_cubit.dart';
import 'package:book_ease/features/my_appointments/presentation/cubit/appointment_details_state.dart';
import 'package:book_ease/features/my_appointments/presentation/cubit/my_appointments_cubit.dart';
import 'package:book_ease/features/my_appointments/presentation/cubit/my_appointments_state.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeMyAppointmentsRepository implements MyAppointmentsRepository {
  List<MyAppointment> appointments = [];
  MyAppointment? appointment;
  Exception? loadError;
  Exception? detailError;
  Exception? cancelError;
  int cancellationCount = 0;

  @override
  Future<void> cancelAppointment(String appointmentId) async {
    cancellationCount++;
    if (cancelError case final error?) throw error;
  }

  @override
  Future<MyAppointment?> getMyAppointment(String appointmentId) async {
    if (detailError case final error?) throw error;
    return appointment;
  }

  @override
  Future<List<MyAppointment>> getMyAppointments() async {
    if (loadError case final error?) throw error;
    return appointments;
  }
}

MyAppointment _appointment({String status = 'confirmed'}) {
  return MyAppointment(
    id: 'appointment-1',
    patientId: 'patient-1',
    doctorId: 'doctor-1',
    doctorName: 'Dr. Morgan Lee',
    doctorImageUrl: '',
    specialtyId: 'cardiology',
    specialtyName: 'Cardiology',
    scheduledAt: DateTime.now().add(const Duration(days: 1)),
    status: status,
  );
}

void main() {
  late _FakeMyAppointmentsRepository repository;

  setUp(() => repository = _FakeMyAppointmentsRepository());

  test('loads an empty appointments collection successfully', () async {
    final cubit = MyAppointmentsCubit(
      GetMyAppointments(repository),
      const AppointmentCategoryPolicy(),
    );
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state, isA<MyAppointmentsLoaded>());
    expect((cubit.state as MyAppointmentsLoaded).appointments, isEmpty);
  });

  test('exposes an initial load failure for retry', () async {
    repository.loadError = const MyAppointmentsException('Unable to load.');
    final cubit = MyAppointmentsCubit(
      GetMyAppointments(repository),
      const AppointmentCategoryPolicy(),
    );
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state, const MyAppointmentsFailure('Unable to load.'));
  });

  test(
    'completes cancellation once and marks the loaded appointment',
    () async {
      repository.appointment = _appointment();
      final cubit = AppointmentDetailsCubit(
        GetMyAppointment(repository),
        CancelAppointment(repository),
        AppointmentCancellationPolicy(),
      );
      addTearDown(cubit.close);

      await cubit.load('appointment-1');
      await cubit.cancel();
      await cubit.cancel();

      final state = cubit.state;
      expect(state, isA<AppointmentDetailsLoaded>());
      if (state is! AppointmentDetailsLoaded) {
        fail('Expected loaded appointment details.');
      }
      expect(state.appointment.status, 'cancelled');
      expect(state.cancellationCompleted, isTrue);
      expect(repository.cancellationCount, 1);
    },
  );

  test('keeps cancellation failures visible and allows a retry', () async {
    repository.appointment = _appointment();
    repository.cancelError = const MyAppointmentsException('Try again.');
    final cubit = AppointmentDetailsCubit(
      GetMyAppointment(repository),
      CancelAppointment(repository),
      AppointmentCancellationPolicy(),
    );
    addTearDown(cubit.close);
    await cubit.load('appointment-1');

    await cubit.cancel();
    expect(
      (cubit.state as AppointmentDetailsLoaded).errorMessage,
      'Try again.',
    );
    repository.cancelError = null;
    await cubit.cancel();

    expect(
      (cubit.state as AppointmentDetailsLoaded).cancellationCompleted,
      isTrue,
    );
    expect(repository.cancellationCount, 2);
  });
}
