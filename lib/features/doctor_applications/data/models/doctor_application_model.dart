import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/doctor_application.dart';

abstract final class DoctorApplicationModel {
  static DoctorApplication? fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    if (data == null) return null;
    final uid = data['applicantUid'];
    if (uid is! String || uid.isEmpty) return null;
    return DoctorApplication(
      id: snapshot.id,
      applicantUid: uid,
      applicantName: _string(data['applicantName']),
      applicantEmail: _string(data['applicantEmail']),
      applicantPhone: _string(data['applicantPhone']),
      profileImageUrl: _string(data['profileImageUrl']),
      specialtyId: _string(data['specialtyId']),
      specialtyName: _string(data['specialtyName']),
      qualification: _string(data['qualification']),
      experienceYears: _integer(data['experienceYears']),
      bio: _string(data['bio']),
      consultationFee: _number(data['consultationFee']),
      clinicAddress: _string(data['clinicAddress']),
      status: DoctorApplicationStatus.fromValue(data['applicationStatus']),
      submittedAt: _dateTime(data['submittedAt']),
      reviewedAt: _dateTime(data['reviewedAt']),
      reviewerUid: _string(data['reviewedBy']).isNotEmpty
          ? _string(data['reviewedBy'])
          : _string(data['reviewerUid']),
      rejectionReason: _string(data['rejectionReason']),
      doctorProfileId: _string(data['doctorProfileId']),
    );
  }

  static String _string(Object? value) => value is String ? value.trim() : '';

  static int _integer(Object? value) => switch (value) {
    int value when value >= 0 => value,
    num value when value.isFinite && value == value.roundToDouble() =>
      value.toInt() >= 0 ? value.toInt() : 0,
    _ => 0,
  };

  static double _number(Object? value) => switch (value) {
    num value when value.isFinite && value >= 0 => value.toDouble(),
    _ => 0,
  };

  static DateTime? _dateTime(Object? value) => switch (value) {
    Timestamp value => value.toDate(),
    DateTime value => value,
    _ => null,
  };
}
