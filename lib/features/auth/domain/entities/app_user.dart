import 'package:equatable/equatable.dart';

import 'doctor_lifecycle_status.dart';
import 'user_role.dart';

class AppUser extends Equatable {
  const AppUser({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    this.doctorLifecycleStatus = DoctorLifecycleStatus.pending,
    this.profileImageUrl = '',
  });

  final String uid;
  final String fullName;
  final String email;
  final String phoneNumber;
  final UserRole role;
  final DoctorLifecycleStatus doctorLifecycleStatus;
  final String profileImageUrl;

  bool get isComplete =>
      uid.isNotEmpty && fullName.trim().isNotEmpty && email.isNotEmpty;

  @override
  List<Object?> get props => [
    uid,
    fullName,
    email,
    phoneNumber,
    role,
    doctorLifecycleStatus,
    profileImageUrl,
  ];
}
