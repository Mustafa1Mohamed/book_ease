import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
            final status = _isLinkedDoctor(doctorSnapshot, user.uid)
                ? DoctorApprovalStatus.fromFirestore(
                    doctorSnapshot.data()?['approvalStatus'],
                  )
                : DoctorApprovalStatus.profileMissing;
            controller.add(profile.withDoctorApprovalStatus(status));
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
    ({AppUserModel? profile, DocumentSnapshot<Map<String, dynamic>>? doctor})
  >
  _resolveProfile(
    String uid, [
    DocumentSnapshot<Map<String, dynamic>>? initialSnapshot,
  ]) async {
    final profileRef = _firestore.collection('users').doc(uid);
    final snapshot = initialSnapshot ?? await profileRef.get();
    if (!snapshot.exists) return (profile: null, doctor: null);
    final rawRole = snapshot.data()?['role'];
    var currentSnapshot = snapshot;
    if (rawRole == null || (rawRole is String && rawRole.trim().isEmpty)) {
      await _firestore.runTransaction<void>((transaction) async {
        final latest = await transaction.get(profileRef);
        final latestRole = latest.data()?['role'];
        if (latest.exists &&
            (latestRole == null ||
                (latestRole is String && latestRole.trim().isEmpty))) {
          transaction.update(profileRef, {
            'role': UserRole.patient.firestoreValue,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
      currentSnapshot = await profileRef.get();
    }
    if (!currentSnapshot.exists) return (profile: null, doctor: null);
    final profile = AppUserModel.fromFirestore(currentSnapshot);
    if (profile.role != UserRole.doctor) {
      return (profile: profile, doctor: null);
    }

    final doctor = await _findDoctorProfile(uid, currentSnapshot.data());
    if (doctor == null) {
      return (
        profile: profile.withDoctorApprovalStatus(
          DoctorApprovalStatus.profileMissing,
        ),
        doctor: null,
      );
    }
    return (
      profile: profile.withDoctorApprovalStatus(
        DoctorApprovalStatus.fromFirestore(doctor.data()?['approvalStatus']),
      ),
      doctor: doctor,
    );
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> _findDoctorProfile(
    String uid,
    Map<String, dynamic>? userData,
  ) async {
    final linkedId = userData?['doctorProfileId'];
    if (linkedId is String && linkedId.trim().isNotEmpty) {
      final linked = await _firestore
          .collection('doctors')
          .doc(linkedId.trim())
          .get();
      if (_isLinkedDoctor(linked, uid)) return linked;
      return null;
    }

    final matches = await _firestore
        .collection('doctors')
        .where('uid', isEqualTo: uid)
        .limit(2)
        .get();
    if (matches.docs.length > 1) return null;
    if (matches.docs case [final doctor]) return doctor;

    final legacy = await _firestore.collection('doctors').doc(uid).get();
    return _isLinkedDoctor(legacy, uid) ? legacy : null;
  }

  bool _isLinkedDoctor(
    DocumentSnapshot<Map<String, dynamic>> doctor,
    String uid,
  ) {
    final data = doctor.data();
    if (data == null) return false;
    final linkedUid = data['uid'];
    return (linkedUid is String && linkedUid == uid) ||
        ((linkedUid == null || linkedUid == '') && doctor.id == uid);
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
