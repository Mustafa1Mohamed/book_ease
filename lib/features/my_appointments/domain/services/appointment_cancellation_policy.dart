import '../entities/appointment_category.dart';
import '../entities/my_appointment.dart';
import 'appointment_category_policy.dart';

class AppointmentCancellationPolicy {
  AppointmentCancellationPolicy({
    this.minimumNotice = Duration.zero,
    this.categoryPolicy = const AppointmentCategoryPolicy(),
  }) {
    if (minimumNotice.isNegative) {
      throw ArgumentError.value(
        minimumNotice,
        'minimumNotice',
        'Must not be negative.',
      );
    }
  }

  static const eligibleStatuses = {
    'confirmed',
    'pending',
    'scheduled',
    'booked',
  };

  final Duration minimumNotice;
  final AppointmentCategoryPolicy categoryPolicy;

  bool canCancel(MyAppointment appointment, DateTime now) {
    final status = appointment.status.trim().toLowerCase();
    return eligibleStatuses.contains(status) &&
        categoryPolicy.categoryOf(appointment, now) ==
            AppointmentCategory.upcoming &&
        appointment.scheduledAt.isAfter(now.add(minimumNotice));
  }

  String get policyDescription {
    if (minimumNotice == Duration.zero) {
      return 'Appointments can be cancelled any time before they start.';
    }
    final minutes = minimumNotice.inMinutes;
    final notice = minutes % 60 == 0
        ? '${minutes ~/ 60} hours'
        : '$minutes minutes';
    return 'Appointments can be cancelled at least $notice before they start.';
  }
}
