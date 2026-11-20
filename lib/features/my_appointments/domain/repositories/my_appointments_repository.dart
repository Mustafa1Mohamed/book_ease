import '../entities/my_appointment.dart';

abstract interface class MyAppointmentsRepository {
  Future<List<MyAppointment>> getMyAppointments();

  Future<MyAppointment?> getMyAppointment(String appointmentId);

  Future<void> cancelAppointment(String appointmentId);
}
