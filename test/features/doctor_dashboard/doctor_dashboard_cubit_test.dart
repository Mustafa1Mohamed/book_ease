import 'package:book_ease/features/doctor_dashboard/domain/entities/doctor_dashboard_data.dart';
import 'package:book_ease/features/doctor_dashboard/domain/errors/doctor_dashboard_exception.dart';
import 'package:book_ease/features/doctor_dashboard/domain/repositories/doctor_dashboard_repository.dart';
import 'package:book_ease/features/doctor_dashboard/domain/services/doctor_appointment_policy.dart';
import 'package:book_ease/features/doctor_dashboard/domain/usecases/complete_doctor_appointment.dart';
import 'package:book_ease/features/doctor_dashboard/domain/usecases/get_doctor_appointment.dart';
import 'package:book_ease/features/doctor_dashboard/domain/usecases/get_doctor_dashboard.dart';
import 'package:book_ease/features/doctor_dashboard/presentation/cubit/doctor_appointment_details_cubit.dart';
import 'package:book_ease/features/doctor_dashboard/presentation/cubit/doctor_appointment_details_state.dart';
import 'package:book_ease/features/doctor_dashboard/presentation/cubit/doctor_dashboard_cubit.dart';
import 'package:book_ease/features/doctor_dashboard/presentation/cubit/doctor_dashboard_state.dart';
import 'package:book_ease/features/home/domain/entities/featured_doctor.dart';
import 'package:book_ease/features/my_appointments/domain/entities/my_appointment.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeDoctorDashboardRepository implements DoctorDashboardRepository {
  DoctorDashboardData? dashboard = const DoctorDashboardData(
    doctor: FeaturedDoctor(
      id: 'doctor-1',
      fullName: 'Dr. Morgan Lee',
      specialtyId: 'cardiology',
      specialtyName: 'Cardiology',
      imageUrl: '',
      rating: null,
      consultationFee: null,
      isAvailable: true,
    ),
    appointments: [],
  );
  MyAppointment? appointment;
  Exception? dashboardError;
  Exception? appointmentError;
  Exception? completionError;
  int completionCount = 0;

  @override
  Future<void> completeAppointment(String appointmentId) async {
    completionCount++;
    if (completionError case final error?) throw error;
  }

  @override
  Future<MyAppointment?> getAppointment(String appointmentId) async {
    if (appointmentError case final error?) throw error;
    return appointment;
  }

  @override
  Future<DoctorDashboardData> getDashboard() async {
    if (dashboardError case final error?) throw error;
    if (dashboard case final value?) return value;
    throw StateError('Fake dashboard data was not configured.');
  }
}

MyAppointment _appointment({
  String status = 'confirmed',
  DateTime? endAt,
}) {
  return MyAppointment(
    id: 'appointment-1',
    patientId: 'patient-1',
    patientName: 'Alex Patient',
    patientPhoneNumber: '555-1234',
    doctorId: 'doctor-1',
    doctorName: 'Dr. Morgan Lee',
    doctorImageUrl: '',
    specialtyId: 'cardiology',
    specialtyName: 'Cardiology',
    scheduledAt: DateTime.now().subtract(const Duration(hours: 1)),
    endAt: endAt ?? DateTime.now().subtract(const Duration(minutes: 1)),
    status: status,
  );
}

void main() {
  late _FakeDoctorDashboardRepository repository;

  setUp(() => repository = _FakeDoctorDashboardRepository());

  test('loads an empty doctor schedule successfully', () async {
    final cubit = DoctorDashboardCubit(GetDoctorDashboard(repository));
    addTearDown(cubit.close);

    await cubit.load();

    final state = cubit.state;
    expect(state, isA<DoctorDashboardLoaded>());
    if (state is! DoctorDashboardLoaded) {
      fail('Expected loaded dashboard.');
    }
    expect(state.data.appointments, isEmpty);
    expect(state.appointmentsForSelectedDate(), isEmpty);
  });

  test('exposes dashboard load errors', () async {
    repository.dashboardError = const DoctorDashboardException('Load failed.');
    final cubit = DoctorDashboardCubit(GetDoctorDashboard(repository));
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state, const DoctorDashboardFailure('Load failed.'));
  });

  test('completes an eligible appointment only once', () async {
    repository.appointment = _appointment();
    final cubit = DoctorAppointmentDetailsCubit(
      GetDoctorAppointment(repository),
      CompleteDoctorAppointment(repository),
      const DoctorAppointmentPolicy(),
    );
    addTearDown(cubit.close);

    await cubit.load('appointment-1');
    await cubit.complete();
    await cubit.complete();

    final state = cubit.state;
    expect(state, isA<DoctorAppointmentDetailsLoaded>());
    if (state is! DoctorAppointmentDetailsLoaded) {
      fail('Expected loaded appointment details.');
    }
    expect(state.appointment.status, 'completed');
    expect(state.completionCompleted, isTrue);
    expect(repository.completionCount, 1);
  });

  test('does not complete future appointments and shows action failures', () async {
    repository.appointment = _appointment(
      endAt: DateTime.now().add(const Duration(hours: 1)),
    );
    final cubit = DoctorAppointmentDetailsCubit(
      GetDoctorAppointment(repository),
      CompleteDoctorAppointment(repository),
      const DoctorAppointmentPolicy(),
    );
    addTearDown(cubit.close);
    await cubit.load('appointment-1');
    await cubit.complete();
    expect(repository.completionCount, 0);

    repository.appointment = _appointment();
    repository.completionError = const DoctorDashboardException('Retry later.');
    await cubit.load('appointment-1');
    await cubit.complete();

    expect(
      (cubit.state as DoctorAppointmentDetailsLoaded).errorMessage,
      'Retry later.',
    );
  });
}
