import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/admin_patient.dart';

abstract final class AdminPatientModel {
  static AdminPatient fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return AdminPatient(
      uid: snapshot.id,
      fullName: _string(data['fullName']),
      email: _string(data['email']),
      phoneNumber: _string(data['phoneNumber']),
      profileImageUrl: _string(data['profileImageUrl']),
      role: _string(data['role']),
      createdAt: _dateTime(data['createdAt']),
      updatedAt: _dateTime(data['updatedAt']),
    );
  }

  static DateTime? _dateTime(Object? value) => switch (value) {
    Timestamp timestamp => timestamp.toDate(),
    DateTime dateTime => dateTime,
    String string => DateTime.tryParse(string),
    _ => null,
  };

  static String _string(Object? value) => value is String ? value.trim() : '';
}
