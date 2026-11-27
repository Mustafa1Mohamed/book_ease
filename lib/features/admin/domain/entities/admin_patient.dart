import 'package:equatable/equatable.dart';

class AdminPatient extends Equatable {
  const AdminPatient({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.profileImageUrl,
    required this.role,
    this.createdAt,
    this.updatedAt,
  });

  final String uid;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String profileImageUrl;
  final String role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  int get profileCompleteness {
    final completedFields = [
      fullName,
      email,
      phoneNumber,
      profileImageUrl,
    ].where((value) => value.trim().isNotEmpty).length;
    return (completedFields * 100 / 4).round();
  }

  @override
  List<Object?> get props => [
    uid,
    fullName,
    email,
    phoneNumber,
    profileImageUrl,
    role,
    createdAt,
    updatedAt,
  ];
}
