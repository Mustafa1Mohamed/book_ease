import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/entities/doctor_lifecycle_status.dart';
import '../../domain/entities/user_role.dart';

class AppUserModel extends AppUser {
  const AppUserModel({
    required super.uid,
    required super.fullName,
    required super.email,
    required super.phoneNumber,
    required super.role,
    super.doctorLifecycleStatus = DoctorLifecycleStatus.pending,
    super.profileImageUrl = '',
  });

  factory AppUserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? <String, dynamic>{};
    return AppUserModel(
      uid: (data['uid'] as String?) ?? snapshot.id,
      fullName: (data['fullName'] as String?)?.trim() ?? '',
      email: (data['email'] as String?)?.trim() ?? '',
      phoneNumber: (data['phoneNumber'] as String?)?.trim() ?? '',
      role: UserRole.fromFirestore(data['role']),
      profileImageUrl: (data['profileImageUrl'] as String?)?.trim() ?? '',
    );
  }

  AppUserModel withDoctorLifecycleStatus(DoctorLifecycleStatus status) =>
      AppUserModel(
        uid: uid,
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        role: role,
        doctorLifecycleStatus: status,
        profileImageUrl: profileImageUrl,
      );

  Map<String, dynamic> toFirestore() => <String, dynamic>{
    'uid': uid,
    'fullName': fullName,
    'email': email,
    'phoneNumber': phoneNumber,
    'role': UserRole.patient.firestoreValue,
    if (profileImageUrl.isNotEmpty) 'profileImageUrl': profileImageUrl,
  };
}
