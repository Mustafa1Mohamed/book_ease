import 'package:equatable/equatable.dart';

class BookingConfirmation extends Equatable {
  const BookingConfirmation({
    required this.appointmentId,
    required this.doctorName,
    required this.startAt,
    required this.endAt,
  });

  final String appointmentId;
  final String doctorName;
  final DateTime startAt;
  final DateTime endAt;

  @override
  List<Object?> get props => [appointmentId, doctorName, startAt, endAt];
}
