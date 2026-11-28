import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/firebase/doctor_profile_resolver.dart';
import '../../domain/entities/doctor_lifecycle_status.dart';
import '../../domain/entities/user_role.dart';
import '../models/app_user_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({required this._firebaseAuth, required this._firestore});

  static const _roleClaimRefreshAttempts = 12;
  static const _roleClaimRefreshInterval = Duration(seconds: 1);

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  Stream<AppUserModel?> authStateChanges() => Stream<AppUserModel?>.multi((
    controller,
  ) {
    StreamSubscription<User?>? authSubscription;
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
    profileSubscription;
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
    doctorSubscription;
    var sessionVersion = 0;
    var profileVersion = 0;

    Future<void> cancelProfileSubscriptions() async {
      final profile = profileSubscription;
      final doctor = doctorSubscription;
      profileSubscription = null;
      doctorSubscription = null;
      await profile?.cancel();
      await doctor?.cancel();
    }

    authSubscription = _firebaseAuth.authStateChanges().listen((user) async {
      final currentSession = ++sessionVersion;
      await cancelProfileSubscriptions();
      if (currentSession != sessionVersion) return;
      if (user == null) {
        controller.add(null);
        return;
      }

      final profileRef = _firestore.collection('users').doc(user.uid);
      profileSubscription = profileRef.snapshots().listen((snapshot) async {
        final currentProfile = ++profileVersion;
        try {
          final result = await _resolveProfile(user.uid, snapshot);
          if (currentSession != sessionVersion ||
              currentProfile != profileVersion) {
            return;
          }
          final profile = result.profile;
          controller.add(profile);
          await doctorSubscription?.cancel();
          doctorSubscription = null;

          final doctor = result.doctor;
          if (profile == null ||
              profile.role != UserRole.doctor ||
              doctor == null) {
            return;
          }
          doctorSubscription = doctor.reference.snapshots().listen((
            doctorSnapshot,
          ) {
            if (currentSession != sessionVersion ||
                currentProfile != profileVersion) {
              return;
            }
            final doctorData = doctorSnapshot.data();
            final userData = result.userData;
            final status =
                doctorData != null &&
                    userData != null &&
                    DoctorProfileResolver.isLinkedProfile(
                      uid: user.uid,
                      doctorId: doctorSnapshot.id,
                      userData: userData,
                      doctorData: doctorData,
                    )
                ? DoctorLifecycleStatus.fromDoctorData(doctorData)
                : DoctorLifecycleStatus.profileMissing;
            controller.add(profile.withDoctorLifecycleStatus(status));
          }, onError: controller.addError);
        } catch (error, stackTrace) {
          if (currentSession == sessionVersion &&
              currentProfile == profileVersion) {
            controller.addError(error, stackTrace);
          }
        }
      }, onError: controller.addError);
    }, onError: controller.addError);

    controller.onCancel = () async {
      sessionVersion++;
      await cancelProfileSubscriptions();
      await authSubscription?.cancel();
    };
  });

  Future<AppUserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await credential.user!.getIdToken(true);
    final uid = credential.user!.uid;
    final profile = await getProfile(uid);
    if (profile == null) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'profile-missing',
        message: 'The user profile does not exist.',
      );
    }
    return profile;
  }

  Future<AppUserModel> signUpWithEmail({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user!;

    late final AppUserModel profile;
    try {
      await user.updateDisplayName(fullName.trim());
      profile = AppUserModel(
        uid: user.uid,
        fullName: fullName.trim(),
        email: email.trim(),
        phoneNumber: phoneNumber.trim(),
        role: UserRole.patient,
      );

      await _firestore.collection('users').doc(user.uid).set(<String, dynamic>{
        ...profile.toFirestore(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      try {
        await user.delete();
      } catch (_) {}
      rethrow;
    }

    await _refreshTokenAfterRoleClaim(user);
    return profile;
  }

  Future<AppUserModel> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn.instance;
    final account = await googleSignIn.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw FirebaseException(
        plugin: 'google_sign_in',
        code: 'missing-id-token',
        message: 'Google did not return a valid authentication token.',
      );
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);
    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final user = userCredential.user!;
    await user.getIdToken(true);
    final document = _firestore.collection('users').doc(user.uid);
    final existing = await document.get();

    if (existing.exists) {
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _refreshTokenAfterRoleClaim(user);
      }
      return (await getProfile(user.uid))!;
    }

    final profile = AppUserModel(
      uid: user.uid,
      fullName: user.displayName?.trim() ?? account.displayName ?? '',
      email: user.email ?? account.email,
      phoneNumber: '',
      role: UserRole.patient,
    );
    await document.set(<String, dynamic>{
      ...profile.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _refreshTokenAfterRoleClaim(user);
    return profile;
  }

  Future<void> _refreshTokenAfterRoleClaim(User user) async {
    for (var attempt = 0; attempt < _roleClaimRefreshAttempts; attempt++) {
      await user.getIdToken(true);
      final tokenResult = await user.getIdTokenResult();
      if (tokenResult.claims?['role'] == 'authenticated') return;
      if (attempt + 1 < _roleClaimRefreshAttempts) {
        await Future<void>.delayed(_roleClaimRefreshInterval);
      }
    }

    throw FirebaseException(
      plugin: 'firebase_auth',
      code: 'supabase-role-claim-pending',
      message: 'The Supabase authentication claim is not available yet.',
    );
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }

  Future<AppUserModel?> getProfile(String uid) async {
    return (await _resolveProfile(uid)).profile;
  }

  Future<
    ({
      AppUserModel? profile,
      DocumentSnapshot<Map<String, dynamic>>? doctor,
      Map<String, dynamic>? userData,
    })
  >
  _resolveProfile(
    String uid, [
    DocumentSnapshot<Map<String, dynamic>>? initialSnapshot,
  ]) async {
    final profileRef = _firestore.collection('users').doc(uid);
    final snapshot = initialSnapshot ?? await profileRef.get();
    if (!snapshot.exists) {
      return (profile: null, doctor: null, userData: null);
    }
    final userData = snapshot.data();
    final profile = AppUserModel.fromFirestore(snapshot);
    if (profile.role != UserRole.doctor) {
      return (profile: profile, doctor: null, userData: userData);
    }

    final doctor = await DoctorProfileResolver(_firestore)
        .resolve(uid: uid, userData: userData);
    if (doctor == null) {
      return (
        profile: profile.withDoctorLifecycleStatus(
          DoctorLifecycleStatus.profileMissing,
        ),
        doctor: null,
        userData: userData,
      );
    }
    return (
      profile: profile.withDoctorLifecycleStatus(
        DoctorLifecycleStatus.fromDoctorData(doctor.data()),
      ),
      doctor: doctor,
      userData: userData,
    );
  }

  Future<AppUserModel> completeProfile({
    required String fullName,
    required String phoneNumber,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(code: 'no-current-user');
    }

    final profile = AppUserModel(
      uid: user.uid,
      fullName: fullName.trim(),
      email: user.email?.trim() ?? '',
      phoneNumber: phoneNumber.trim(),
      role: UserRole.patient,
    );
    final profileRef = _firestore.collection('users').doc(user.uid);
    final existing = await profileRef.get();
    final data = <String, dynamic>{
      ...profile.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (!existing.exists) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }
    await profileRef.set(data, SetOptions(merge: true));
    return profile;
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await _firebaseAuth.signOut();
  }
}
