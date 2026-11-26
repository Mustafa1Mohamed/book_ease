import 'package:book_ease/features/admin/data/models/admin_doctor_audit_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'maps allowlisted audit fields and timestamp from the backend schema',
    () {
      final createdAt = DateTime.utc(2030, 4, 5, 6, 7);
      final event = AdminDoctorAuditModel.fromData('operation-1', {
        'actorUid': 'admin-1',
        'targetDoctorUid': 'doctor-1',
        'doctorProfileId': 'profile-1',
        'action': 'suspend',
        'previousApprovalStatus': 'approved',
        'newApprovalStatus': 'approved',
        'previousAdministrativeStatus': 'active',
        'newAdministrativeStatus': 'suspended',
        'reason': 'Policy review',
        'createdAt': Timestamp.fromDate(createdAt),
        'unexpected': 'ignored',
      });

      expect(event.id, 'operation-1');
      expect(event.actorUid, 'admin-1');
      expect(event.action, 'suspend');
      expect(event.previousAdministrativeStatus, 'active');
      expect(event.newAdministrativeStatus, 'suspended');
      expect(event.reason, 'Policy review');
      expect(event.createdAt?.toUtc(), createdAt);
    },
  );
}
