import 'package:equatable/equatable.dart';

class AppointmentSlot extends Equatable {
  const AppointmentSlot({
    required this.id,
    required this.startAt,
    required this.endAt,
  });

  final String id;
  final DateTime startAt;
  final DateTime endAt;

  @override
  List<Object?> get props => [id, startAt, endAt];
}
