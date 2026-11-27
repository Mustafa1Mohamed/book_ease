import 'package:book_ease/core/router/app_router.dart';
import 'package:book_ease/features/auth/data/models/app_user_model.dart';
import 'package:book_ease/features/auth/domain/entities/app_user.dart';
import 'package:book_ease/features/auth/domain/entities/doctor_lifecycle_status.dart';
import 'package:book_ease/features/auth/domain/entities/user_role.dart';
import 'package:book_ease/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

AppUser _user(
  UserRole role, {
  DoctorLifecycleStatus lifecycleStatus = DoctorLifecycleStatus.pending,
}) {
  return AppUser(
    uid: 'user-1',
    fullName: 'Test User',
    email: 'test@example.com',
    phoneNumber: '',
    role: role,
    doctorLifecycleStatus: lifecycleStatus,
  );
}

void main() {
  group('role parsing and defaults', () {
    test(
      'missing roles preserve patient access but invalid roles are unknown',
      () {
        expect(UserRole.fromFirestore(null), UserRole.patient);
        expect(UserRole.fromFirestore(' '), UserRole.patient);
        expect(UserRole.fromFirestore('DOCTOR'), UserRole.doctor);
        expect(UserRole.fromFirestore('superuser'), UserRole.unknown);
        expect(UserRole.fromFirestore(42), UserRole.unknown);
      },
    );

    test('doctor status parsing distinguishes missing and invalid fields', () {
      expect(
        DoctorApprovalStatus.fromFirestore(null),
        DoctorApprovalStatus.unknown,
      );
      expect(
        DoctorApprovalStatus.fromFirestore('approved'),
        DoctorApprovalStatus.approved,
      );
      expect(
        DoctorLifecycleStatus.fromDoctorData({}),
        DoctorLifecycleStatus.pending,
      );
      expect(
        DoctorLifecycleStatus.fromDoctorData({'approvalStatus': 'approved'})
            .canOperate,
        isTrue,
      );
      for (final value in [null, '', 'unknown', 4]) {
        expect(
          DoctorLifecycleStatus.fromDoctorData({
            'approvalStatus': 'approved',
            'administrativeStatus': value,
          }).canOperate,
          isFalse,
        );
      }
      expect(
        DoctorLifecycleStatus.fromDoctorData({
          'approvalStatus': 'pending',
          'administrativeStatus': 'suspended',
        }).isValid,
        isFalse,
      );
      expect(
        DoctorLifecycleStatus.fromDoctorData({
          'approvalStatus': 'approved',
          'administrativeStatus': 'suspended',
        }).isSuspended,
        isTrue,
      );
      expect(
        DoctorApprovalStatus.fromFirestore('anything-else'),
        DoctorApprovalStatus.unknown,
      );
    });

    test('new profiles serialize as patients', () {
      final profile = AppUserModel(
        uid: 'user-1',
        fullName: 'Test User',
        email: 'test@example.com',
        phoneNumber: '',
        role: UserRole.patient,
      );

      expect(profile.toFirestore()['role'], 'patient');
    });
  });

  group('role-based redirects', () {
    test('unauthenticated users cannot open protected routes', () {
      expect(
        AppRouter.redirectFor(const AuthUnauthenticated(), '/appointments'),
        '/login',
      );
      expect(
        AppRouter.redirectFor(const AuthUnauthenticated(), '/admin'),
        '/login',
      );
      expect(
        AppRouter.redirectFor(const AuthUnauthenticated(), '/admin/patients'),
        '/login',
      );
      expect(
        AppRouter.redirectFor(const AuthUnauthenticated(), '/register'),
        isNull,
      );
    });

    test(
      'patients can stay in patient routes but not doctor or admin routes',
      () {
        const state = AuthAuthenticated(
          AppUser(
            uid: 'patient-1',
            fullName: 'Patient',
            email: 'patient@example.com',
            phoneNumber: '',
            role: UserRole.patient,
          ),
        );

        expect(AppRouter.redirectFor(state, '/appointments'), isNull);
        expect(AppRouter.redirectFor(state, '/doctor-dashboard'), '/home');
        expect(AppRouter.redirectFor(state, '/admin'), '/home');
        expect(AppRouter.redirectFor(state, '/admin/appointments'), '/home');
        expect(AppRouter.redirectFor(state, '/admin/doctors'), '/home');
        expect(AppRouter.redirectFor(state, '/admin/patients'), '/home');
        expect(
          AppRouter.redirectFor(state, '/admin/patients/patient-1'),
          '/home',
        );
      },
    );

    test('doctors are gated by approval and isolated from patient routes', () {
      final pending = AuthAuthenticated(_user(UserRole.doctor));
      final approved = AuthAuthenticated(
        _user(
          UserRole.doctor,
          lifecycleStatus: DoctorLifecycleStatus.fromDoctorData({
            'approvalStatus': 'approved',
          }),
        ),
      );
      final rejected = AuthAuthenticated(
        _user(
          UserRole.doctor,
          lifecycleStatus: DoctorLifecycleStatus.fromDoctorData({
            'approvalStatus': 'rejected',
          }),
        ),
      );
      final suspended = AuthAuthenticated(
        _user(
          UserRole.doctor,
          lifecycleStatus: DoctorLifecycleStatus.fromDoctorData({
            'approvalStatus': 'approved',
            'administrativeStatus': 'suspended',
          }),
        ),
      );
      final invalid = AuthAuthenticated(
        _user(
          UserRole.doctor,
          lifecycleStatus: DoctorLifecycleStatus.fromDoctorData({
            'approvalStatus': 'approved',
            'administrativeStatus': null,
          }),
        ),
      );

      expect(
        AppRouter.redirectFor(pending, '/doctor-dashboard'),
        '/account-status',
      );
      expect(AppRouter.redirectFor(pending, '/account-status'), isNull);
      expect(
        AppRouter.redirectFor(rejected, '/doctor-dashboard'),
        '/account-status',
      );
      expect(
        AppRouter.redirectFor(suspended, '/doctor-dashboard'),
        '/account-status',
      );
      expect(AppRouter.redirectFor(suspended, '/account-status'), isNull);
      expect(
        AppRouter.redirectFor(invalid, '/doctor-dashboard'),
        '/account-status',
      );
      expect(
        AppRouter.redirectFor(approved, '/appointments'),
        '/doctor-dashboard',
      );
      expect(AppRouter.redirectFor(approved, '/admin'), '/doctor-dashboard');
      expect(AppRouter.redirectFor(approved, '/doctor-dashboard'), isNull);
    });

    test(
      'admins have a distinct landing route and unknown roles stay restricted',
      () {
        final admin = AuthAuthenticated(_user(UserRole.admin));
        final unknown = AuthAuthenticated(_user(UserRole.unknown));

        expect(AppRouter.redirectFor(admin, '/home'), '/admin');
        expect(AppRouter.redirectFor(admin, '/admin'), isNull);
        expect(AppRouter.redirectFor(admin, '/admin/dashboard'), isNull);
        expect(AppRouter.redirectFor(admin, '/admin/doctors'), isNull);
        expect(AppRouter.redirectFor(admin, '/admin/patients'), isNull);
        expect(
          AppRouter.redirectFor(admin, '/admin/patients/patient-1'),
          isNull,
        );
        expect(
          AppRouter.redirectFor(admin, '/admin/doctors/profile-1'),
          isNull,
        );
        expect(AppRouter.redirectFor(unknown, '/home'), '/account-status');
        expect(AppRouter.redirectFor(unknown, '/admin'), '/account-status');
      },
    );
  });
}
