import '../entities/appointment_category.dart';
import '../entities/my_appointment.dart';

class AppointmentCategoryPolicy {
  const AppointmentCategoryPolicy();

  static const _cancelledStatuses = {'cancelled', 'canceled', 'rejected'};
  static const _completedStatuses = {
    'completed',
    'done',
    'fulfilled',
    'no_show',
    'noshow',
  };

  AppointmentCategory categoryOf(MyAppointment appointment, DateTime now) {
    final status = appointment.status.trim().toLowerCase();
    if (_cancelledStatuses.contains(status)) {
      return AppointmentCategory.cancelled;
    }
    if (_completedStatuses.contains(status) ||
        !appointment.scheduledAt.isAfter(now)) {
      return AppointmentCategory.completed;
    }
    return AppointmentCategory.upcoming;
  }
}
