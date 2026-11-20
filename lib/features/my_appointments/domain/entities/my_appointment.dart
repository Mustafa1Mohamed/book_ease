import 'package:equatable/equatable.dart';

class MyAppointment extends Equatable {
  const MyAppointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.doctorImageUrl,
    required this.specialtyId,
    required this.specialtyName,
    required this.scheduledAt,
    required this.status,
    this.endAt,
    this.timeLabel = '',
    this.consultationType = '',
    this.consultationDurationMinutes,
    this.clinicName = '',
    this.clinicAddress = '',
    this.consultationFee,
    this.slotId = '',
    this.createdAt,
    this.cancelledAt,
    this.patientName = '',
    this.patientImageUrl = '',
    this.patientPhoneNumber = '',
  });

  final String id;
  final String patientId;
  final String doctorId;
  final String doctorName;
  final String doctorImageUrl;
  final String specialtyId;
  final String specialtyName;
  final DateTime scheduledAt;
  final DateTime? endAt;
  final String timeLabel;
  final String status;
  final String consultationType;
  final int? consultationDurationMinutes;
  final String clinicName;
  final String clinicAddress;
  final double? consultationFee;
  final String slotId;
  final DateTime? createdAt;
  final DateTime? cancelledAt;
  final String patientName;
  final String patientImageUrl;
  final String patientPhoneNumber;

  MyAppointment copyWith({
    String? status,
    DateTime? cancelledAt,
    String? doctorName,
    String? doctorImageUrl,
    String? specialtyName,
    String? consultationType,
    int? consultationDurationMinutes,
    String? clinicName,
    String? clinicAddress,
  }) {
    return MyAppointment(
      id: id,
      patientId: patientId,
      doctorId: doctorId,
      doctorName: doctorName ?? this.doctorName,
      doctorImageUrl: doctorImageUrl ?? this.doctorImageUrl,
      specialtyId: specialtyId,
      specialtyName: specialtyName ?? this.specialtyName,
      scheduledAt: scheduledAt,
      endAt: endAt,
      timeLabel: timeLabel,
      status: status ?? this.status,
      consultationType: consultationType ?? this.consultationType,
      consultationDurationMinutes:
          consultationDurationMinutes ?? this.consultationDurationMinutes,
      clinicName: clinicName ?? this.clinicName,
      clinicAddress: clinicAddress ?? this.clinicAddress,
      consultationFee: consultationFee,
      slotId: slotId,
      createdAt: createdAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      patientName: patientName,
      patientImageUrl: patientImageUrl,
      patientPhoneNumber: patientPhoneNumber,
    );
  }

  @override
  List<Object?> get props => [
    id,
    patientId,
    doctorId,
    doctorName,
    doctorImageUrl,
    specialtyId,
    specialtyName,
    scheduledAt,
    endAt,
    timeLabel,
    status,
    consultationType,
    consultationDurationMinutes,
    clinicName,
    clinicAddress,
    consultationFee,
    slotId,
    createdAt,
    cancelledAt,
    patientName,
    patientImageUrl,
    patientPhoneNumber,
  ];
}
