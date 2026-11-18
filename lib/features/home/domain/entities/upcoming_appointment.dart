import 'package:equatable/equatable.dart';

class UpcomingAppointment extends Equatable {
  const UpcomingAppointment({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.specialtyId,
    required this.specialtyName,
    required this.doctorImageUrl,
    required this.scheduledAt,
    required this.timeLabel,
    required this.status,
  });

  final String id;
  final String doctorId;
  final String doctorName;
  final String specialtyId;
  final String specialtyName;
  final String doctorImageUrl;
  final DateTime scheduledAt;
  final String timeLabel;
  final String status;

  @override
  List<Object?> get props => [
    id,
    doctorId,
    doctorName,
    specialtyId,
    specialtyName,
    doctorImageUrl,
    scheduledAt,
    timeLabel,
    status,
  ];
}
