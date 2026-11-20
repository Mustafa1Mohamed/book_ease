import '../../../my_appointments/domain/entities/my_appointment.dart';

class DoctorAppointmentPolicy {
  const DoctorAppointmentPolicy();

  bool canComplete(MyAppointment appointment, DateTime now) {
    final endAt = appointment.endAt;
    return appointment.status.trim().toLowerCase() == 'confirmed' &&
        endAt != null &&
        endAt.isAfter(appointment.scheduledAt) &&
        !endAt.isAfter(now);
  }

  bool isUpcoming(MyAppointment appointment, DateTime now) {
    final status = appointment.status.trim().toLowerCase();
    return appointment.scheduledAt.isAfter(now) &&
        status != 'cancelled' &&
        status != 'canceled' &&
        status != 'rejected' &&
        status != 'completed';
  }

  int todayCount(List<MyAppointment> appointments, DateTime now) =>
      appointments.where((appointment) {
        final date = appointment.scheduledAt.toLocal();
        final localNow = now.toLocal();
        return date.year == localNow.year &&
            date.month == localNow.month &&
            date.day == localNow.day;
      }).length;
}
