import 'package:equatable/equatable.dart';

class PatientProfile extends Equatable {
  const PatientProfile({
    required this.fullName,
    required this.imageUrl,
    required this.role,
  });

  final String fullName;
  final String imageUrl;
  final String role;

  @override
  List<Object?> get props => [fullName, imageUrl, role];
}
