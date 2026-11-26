import 'package:book_ease/features/admin/data/models/admin_doctor_model.dart';
import 'package:book_ease/features/admin/domain/entities/admin_doctor.dart';
import 'package:book_ease/features/admin/domain/entities/admin_doctor_action.dart';
import 'package:book_ease/features/auth/domain/entities/doctor_lifecycle_status.dart';
import 'package:book_ease/features/auth/domain/entities/user_role.dart';
import 'package:flutter_test/flutter_test.dart';

AdminDoctor _doctor(Map<String, dynamic> data) {
  final lifecycle = DoctorLifecycleStatus.fromDoctorData(data);
  return AdminDoctor(
    id: 'profile-1',
    uid: 'doctor-1',
    name: 'Doctor',
    email: 'doctor@example.com',
    phoneNumber: '',
    profileImageUrl: '',
    specialtyId: 'specialty-1',
    specialtyName: 'Family medicine',
    consultationFee: 50,
    biography: '',
    qualifications: const [],
    yearsExperience: null,
    languages: const [],
    clinicName: '',
    clinicAddress: '',
    lifecycle: lifecycle,
    warnings: const [],
    identityVerified: true,
  );
}

void main() {
  test('missing lifecycle fields use the approved legacy defaults', () {
    final doctor = AdminDoctorModel.fromSnapshots(
      id: 'doctor-1',
      doctor: {'uid': 'doctor-1'},
      user: {'role': 'doctor'},
      identityVerified: true,
      identityAmbiguous: false,
    );

    expect(doctor.lifecycle.approvalStatus, DoctorApprovalStatus.pending);
    expect(
      doctor.lifecycle.administrativeStatus,
      DoctorAdministrativeStatus.active,
    );
    expect(doctor.warnings, contains(AdminDoctorWarning.approvalStatusMissing));
    expect(
      doctor.warnings,
      contains(AdminDoctorWarning.administrativeStatusMissing),
    );
    expect(AdminDoctorActionPolicy.actionsFor(doctor), [
      AdminDoctorAction.approve,
      AdminDoctorAction.reject,
    ]);
  });

  test('null, blank, unknown, and malformed statuses fail closed', () {
    for (final value in [null, '', 'not-a-status', 8]) {
      final lifecycle = DoctorLifecycleStatus.fromDoctorData({
        'approvalStatus': 'approved',
        'administrativeStatus': value,
      });
      expect(lifecycle.isValid, isFalse, reason: 'value: $value');
      expect(lifecycle.canOperate, isFalse, reason: 'value: $value');
    }

    final invalidCombination = DoctorLifecycleStatus.fromDoctorData({
      'approvalStatus': 'pending',
      'administrativeStatus': 'suspended',
    });
    expect(invalidCombination.isValid, isFalse);
    expect(
      AdminDoctorActionPolicy.actionsFor(
        _doctor({
          'approvalStatus': 'rejected',
          'administrativeStatus': 'suspended',
        }),
      ),
      isEmpty,
    );
  });

  test('only lifecycle-approved actions are offered', () {
    expect(
      AdminDoctorActionPolicy.actionsFor(
        _doctor({
          'approvalStatus': 'pending',
          'administrativeStatus': 'active',
        }),
      ),
      [AdminDoctorAction.approve, AdminDoctorAction.reject],
    );
    expect(
      AdminDoctorActionPolicy.actionsFor(
        _doctor({
          'approvalStatus': 'approved',
          'administrativeStatus': 'active',
        }),
      ),
      [AdminDoctorAction.suspend],
    );
    expect(
      AdminDoctorActionPolicy.actionsFor(
        _doctor({
          'approvalStatus': 'approved',
          'administrativeStatus': 'suspended',
        }),
      ),
      [AdminDoctorAction.restore],
    );
    expect(
      AdminDoctorActionPolicy.actionsFor(
        _doctor({
          'approvalStatus': 'rejected',
          'administrativeStatus': 'active',
        }),
      ),
      isEmpty,
    );
  });

  test('ambiguous identities cannot expose lifecycle actions', () {
    final doctor = _doctor({
      'approvalStatus': 'pending',
      'administrativeStatus': 'active',
    });
    final ambiguous = AdminDoctor(
      id: doctor.id,
      uid: doctor.uid,
      name: doctor.name,
      email: doctor.email,
      phoneNumber: doctor.phoneNumber,
      profileImageUrl: doctor.profileImageUrl,
      specialtyId: doctor.specialtyId,
      specialtyName: doctor.specialtyName,
      consultationFee: doctor.consultationFee,
      biography: doctor.biography,
      qualifications: doctor.qualifications,
      yearsExperience: doctor.yearsExperience,
      languages: doctor.languages,
      clinicName: doctor.clinicName,
      clinicAddress: doctor.clinicAddress,
      lifecycle: doctor.lifecycle,
      warnings: const [AdminDoctorWarning.identityAmbiguous],
      identityVerified: false,
    );

    expect(AdminDoctorActionPolicy.actionsFor(ambiguous), isEmpty);
  });

  test(
    'model marks unresolved and duplicate profile identities for review',
    () {
      final ambiguous = AdminDoctorModel.fromSnapshots(
        id: 'profile-2',
        doctor: {'uid': 'doctor-1'},
        user: {'role': 'doctor', 'doctorProfileId': 'profile-1'},
        identityVerified: false,
        identityAmbiguous: true,
      );

      expect(ambiguous.needsReview, isTrue);
      expect(ambiguous.canAdminister, isFalse);
      expect(
        ambiguous.warnings,
        contains(AdminDoctorWarning.identityAmbiguous),
      );
    },
  );

  test('missing doctor profiles are invalid and cannot receive actions', () {
    final missing = AdminDoctorModel.missingProfile(
      uid: 'doctor-1',
      user: {'role': 'doctor', 'email': 'doctor@example.com'},
      identityAmbiguous: false,
    );

    expect(missing.lifecycle.isValid, isFalse);
    expect(missing.identityVerified, isFalse);
    expect(missing.warnings, contains(AdminDoctorWarning.missingDoctorProfile));
    expect(AdminDoctorActionPolicy.actionsFor(missing), isEmpty);
  });
}
