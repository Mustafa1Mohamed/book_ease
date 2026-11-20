import '../../../home/data/models/appointment_schedule_parser.dart';
import '../../../home/data/models/featured_doctor_model.dart';
import '../../domain/entities/my_appointment.dart';

abstract final class MyAppointmentModel {
  static MyAppointment? fromMap(String id, Map<String, dynamic> data) {
    final scheduledAt =
        AppointmentScheduleParser.parse(data['appointmentAt'], null) ??
        AppointmentScheduleParser.parse(
          data['appointmentDate'],
          data['appointmentTime'],
        );
    if (scheduledAt == null) return null;

    final location = data['location'];
    return MyAppointment(
      id: id,
      patientId: _string(data['patientId']),
      doctorId: _string(data['doctorId']),
      doctorName: _string(data['doctorName']),
      doctorImageUrl: _string(data['doctorImageUrl']),
      specialtyId: _string(data['specialtyId']),
      specialtyName: _string(data['specialtyName']),
      scheduledAt: scheduledAt,
      endAt: _dateTime(data['appointmentEndAt']),
      timeLabel: _string(data['appointmentTime']),
      status: _string(data['status']),
      consultationType: _string(
        data['consultationType'] ?? data['consultationMode'],
      ),
      consultationDurationMinutes: _integer(
        data['consultationDurationMinutes'],
      ),
      clinicName: _string(data['clinicName']),
      clinicAddress: _string(data['clinicAddress']).isNotEmpty
          ? _string(data['clinicAddress'])
          : _locationAddress(location),
      consultationFee: _number(data['consultationFee']),
      slotId: _string(data['slotId']),
      createdAt: _dateTime(data['createdAt']),
      cancelledAt: _dateTime(data['cancelledAt']),
      patientName: _string(data['patientName']),
      patientImageUrl: _string(data['patientImageUrl']),
      patientPhoneNumber: _string(data['patientPhoneNumber']),
    );
  }

  static MyAppointment withDoctorDetails(
    MyAppointment appointment,
    String documentId,
    Map<String, dynamic> data, {
    required Map<String, String> specialtyNamesById,
  }) {
    final doctor = FeaturedDoctorModel.fromMap(
      documentId,
      data,
      specialtyNamesById: specialtyNamesById,
    );
    final locationAddress = _locationAddress(data['location']);
    return appointment.copyWith(
      doctorName: _first(appointment.doctorName, doctor?.fullName ?? ''),
      doctorImageUrl: _first(
        appointment.doctorImageUrl,
        doctor?.imageUrl ?? '',
      ),
      specialtyName: _first(
        appointment.specialtyName,
        doctor?.specialtyName ?? '',
      ),
      consultationType: _first(
        appointment.consultationType,
        _string(data['consultationType'] ?? data['consultationMode']),
      ),
      consultationDurationMinutes:
          appointment.consultationDurationMinutes ??
          doctor?.consultationDurationMinutes,
      clinicName: _first(
        appointment.clinicName,
        doctor?.clinicName ?? _string(data['clinicName']),
      ),
      clinicAddress: _first(
        appointment.clinicAddress,
        doctor?.clinicAddress ?? _string(data['clinicAddress']),
        locationAddress,
      ),
    );
  }

  static DateTime? _dateTime(Object? value) =>
      AppointmentScheduleParser.parse(value, null);

  static String _locationAddress(Object? location) {
    if (location is String) return location.trim();
    if (location is Map) {
      return _string(
        location['address'] ?? location['clinicAddress'] ?? location['name'],
      );
    }
    return '';
  }

  static String _first(String first, [String second = '', String third = '']) {
    if (first.trim().isNotEmpty) return first.trim();
    if (second.trim().isNotEmpty) return second.trim();
    return third.trim();
  }

  static String _string(Object? value) =>
      value is String ? value.trim() : '';

  static int? _integer(Object? value) {
    final number = switch (value) {
      int value => value,
      num value when value.isFinite && value == value.roundToDouble() =>
        value.toInt(),
      String value => int.tryParse(value),
      _ => null,
    };
    return number != null && number >= 0 ? number : null;
  }

  static double? _number(Object? value) {
    final number = switch (value) {
      num value => value.toDouble(),
      String value => double.tryParse(value),
      _ => null,
    };
    return number != null && number.isFinite && number >= 0 ? number : null;
  }
}
