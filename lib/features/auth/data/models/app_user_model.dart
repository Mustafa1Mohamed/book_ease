import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/app_user.dart';

class AppUserModel extends AppUser {
  const AppUserModel({
    required super.uid,
    required super.fullName,
    required super.email,
    required super.phoneNumber,
    required super.role,
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
      role: (data['role'] as String?) ?? 'patient',
      profileImageUrl: (data['profileImageUrl'] as String?)?.trim() ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => <String, dynamic>{
    'uid': uid,
    'fullName': fullName,
    'email': email,
    'phoneNumber': phoneNumber,
    'role': 'patient',
    if (profileImageUrl.isNotEmpty) 'profileImageUrl': profileImageUrl,
  };
}
