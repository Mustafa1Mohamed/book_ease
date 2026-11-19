import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../auth/data/models/app_user_model.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../domain/errors/profile_exception.dart';

class ProfileRemoteDataSource {
  const ProfileRemoteDataSource(
    this._firebaseAuth,
    this._firestore,
    this._storage,
  );

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  Future<AppUser> getCurrentProfile() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const ProfileException('Sign in to view your profile.');
    }

    final snapshot = await _firestore.collection('users').doc(user.uid).get();
    if (!snapshot.exists) {
      throw const ProfileException(
        'Your patient profile could not be found. Please sign out and sign in again.',
      );
    }
    final profile = AppUserModel.fromFirestore(snapshot);
    if (profile.role.trim().toLowerCase() != 'patient') {
      throw const ProfileException(
        'Profile settings are only available to patient accounts.',
      );
    }
    return profile;
  }

  Future<AppUser> updateProfile({
    required String fullName,
    required String phoneNumber,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const ProfileException('Sign in to update your profile.');
    }
    await _firestore.collection('users').doc(user.uid).update({
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return getCurrentProfile();
  }

  Future<AppUser> uploadProfileImage({
    required Uint8List bytes,
    required void Function(double progress) onProgress,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const ProfileException('Sign in to update your profile photo.');
    }
    final imageRef = _storage
        .ref()
        .child('users/${user.uid}/profile/${DateTime.now().microsecondsSinceEpoch}.jpg');
    final task = imageRef.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    await for (final snapshot in task.snapshotEvents) {
      final total = snapshot.totalBytes;
      onProgress(total == 0 ? 1 : snapshot.bytesTransferred / total);
    }
    final downloadUrl = await imageRef.getDownloadURL();
    await _firestore.collection('users').doc(user.uid).update({
      'profileImageUrl': downloadUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return getCurrentProfile();
  }
}
