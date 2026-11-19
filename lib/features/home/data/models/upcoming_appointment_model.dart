import '../../domain/entities/featured_doctor.dart';
import '../../domain/entities/upcoming_appointment.dart';
import 'appointment_schedule_parser.dart';

abstract final class UpcomingAppointmentModel {
  static UpcomingAppointment? fromMap(String id, Map<String, dynamic> data) {
    final scheduledAt =
        AppointmentScheduleParser.parse(data['appointmentAt'], null) ??
        AppointmentScheduleParser.parse(
          data['appointmentDate'],
          data['appointmentTime'],
        );
    if (scheduledAt == null) return null;

    return UpcomingAppointment(
      id: id,
      doctorId: _string(data['doctorId']),
      doctorName: _string(data['doctorName']),
      specialtyId: _string(data['specialtyId']),
      specialtyName: _string(data['specialtyName']),
      doctorImageUrl: _string(data['doctorImageUrl']),
      scheduledAt: scheduledAt,
      timeLabel: _string(data['appointmentTime']),
      status: _string(data['status']),
    );
  }

  static UpcomingAppointment withDoctor(
    UpcomingAppointment appointment,
    FeaturedDoctor? doctor,
  ) {
    if (doctor == null) return appointment;
    return UpcomingAppointment(
      id: appointment.id,
      doctorId: appointment.doctorId,
      doctorName: appointment.doctorName.isNotEmpty
          ? appointment.doctorName
          : doctor.fullName,
      specialtyId: appointment.specialtyId.isNotEmpty
          ? appointment.specialtyId
          : doctor.specialtyId,
      specialtyName: appointment.specialtyName.isNotEmpty
          ? appointment.specialtyName
          : doctor.specialtyName,
      doctorImageUrl: appointment.doctorImageUrl.isNotEmpty
          ? appointment.doctorImageUrl
          : doctor.imageUrl,
      scheduledAt: appointment.scheduledAt,
      timeLabel: appointment.timeLabel,
      status: appointment.status,
    );
  }

  static UpcomingAppointment withSpecialtyName(
    UpcomingAppointment appointment,
    String specialtyName,
  ) {
    if (appointment.specialtyName.isNotEmpty || specialtyName.isEmpty) {
      return appointment;
    }
    return UpcomingAppointment(
      id: appointment.id,
      doctorId: appointment.doctorId,
      doctorName: appointment.doctorName,
      specialtyId: appointment.specialtyId,
      specialtyName: specialtyName,
      doctorImageUrl: appointment.doctorImageUrl,
      scheduledAt: appointment.scheduledAt,
      timeLabel: appointment.timeLabel,
      status: appointment.status,
    );
  }

  static bool isUpcoming(UpcomingAppointment appointment, DateTime now) {
    const finishedStatuses = {'cancelled', 'canceled', 'completed', 'rejected'};
    return appointment.scheduledAt.isAfter(now) &&
        !finishedStatuses.contains(appointment.status.trim().toLowerCase());
  }

  static String _string(Object? value) => value is String ? value : '';
}
