import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  const AppUser({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    this.profileImageUrl = '',
  });

  final String uid;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String role;
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
    profileImageUrl,
  ];
}
