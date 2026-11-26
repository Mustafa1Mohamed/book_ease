import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/admin_doctor_audit_event.dart';

abstract final class AdminDoctorAuditModel {
  static AdminDoctorAuditEvent fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) => fromData(snapshot.id, snapshot.data() ?? const <String, dynamic>{});

  static AdminDoctorAuditEvent fromData(String id, Map<String, dynamic> data) {
    return AdminDoctorAuditEvent(
      id: id,
      actorUid: _string(data['actorUid']),
      targetDoctorUid: _string(data['targetDoctorUid']),
      doctorProfileId: _string(data['doctorProfileId']),
      action: _string(data['action']),
      previousApprovalStatus: _string(data['previousApprovalStatus']),
      newApprovalStatus: _string(data['newApprovalStatus']),
      previousAdministrativeStatus: _string(
        data['previousAdministrativeStatus'],
      ),
      newAdministrativeStatus: _string(data['newAdministrativeStatus']),
      reason: _string(data['reason']),
      createdAt: AdminDoctorModelTimestamp.read(data['createdAt']),
    );
  }

  static String _string(Object? value) => value is String ? value.trim() : '';
}

abstract final class AdminDoctorModelTimestamp {
  static DateTime? read(Object? value) => switch (value) {
    Timestamp value => value.toDate(),
    DateTime value => value,
    _ => null,
  };
}
