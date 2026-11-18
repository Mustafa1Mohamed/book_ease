import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/app_user_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({
    required this._firebaseAuth,
    required this._firestore,
  });

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  Stream<AppUserModel?> authStateChanges() async* {
    await for (final user in _firebaseAuth.authStateChanges()) {
      if (user == null) {
        yield null;
      } else {
        yield await getProfile(user.uid);
      }
    }
  }

  Future<AppUserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
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

    try {
      await user.updateDisplayName(fullName.trim());
      final profile = AppUserModel(
        uid: user.uid,
        fullName: fullName.trim(),
        email: email.trim(),
        phoneNumber: phoneNumber.trim(),
        role: 'patient',
      );

      await _firestore.collection('users').doc(user.uid).set(<String, dynamic>{
        ...profile.toFirestore(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return profile;
    } catch (_) {
      try {
        await user.delete();
      } catch (_) {}
      rethrow;
    }
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
    final document = _firestore.collection('users').doc(user.uid);
    final existing = await document.get();

    if (existing.exists) {
      final existingProfile = AppUserModel.fromFirestore(existing);
      await document.set(<String, dynamic>{
        'uid': user.uid,
        'fullName': existingProfile.fullName.isEmpty
            ? (user.displayName?.trim() ?? account.displayName ?? '')
            : existingProfile.fullName,
        'email': existingProfile.email.isEmpty
            ? user.email ?? account.email
            : existingProfile.email,
        'phoneNumber': existingProfile.phoneNumber,
        'role': existingProfile.role,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return AppUserModel.fromFirestore(await document.get());
    }

    final profile = AppUserModel(
      uid: user.uid,
      fullName: user.displayName?.trim() ?? account.displayName ?? '',
      email: user.email ?? account.email,
      phoneNumber: '',
      role: 'patient',
    );
    await document.set(<String, dynamic>{
      ...profile.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return profile;
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }

  Future<AppUserModel?> getProfile(String uid) async {
    final snapshot = await _firestore.collection('users').doc(uid).get();
    if (!snapshot.exists) return null;
    return AppUserModel.fromFirestore(snapshot);
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
      role: 'patient',
    );
    await _firestore.collection('users').doc(user.uid).set(<String, dynamic>{
      ...profile.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return profile;
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await _firebaseAuth.signOut();
  }
}
