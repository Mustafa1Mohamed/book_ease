import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/data/models/app_user_model.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../domain/errors/profile_exception.dart';

class ProfileRemoteDataSource {
  const ProfileRemoteDataSource(
    this._firebaseAuth,
    this._firestore,
    this._supabase,
  );

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final SupabaseClient _supabase;

  static const _bucketName = 'profile-images';

  Future<AppUser> getCurrentProfile() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const ProfileException('Sign in to view your profile.');
    }

    final snapshot = await _firestore.collection('users').doc(user.uid).get();
    if (!snapshot.exists) {
      throw const ProfileException(
        'Your profile could not be found. Please sign out and sign in again.',
      );
    }
    return AppUserModel.fromFirestore(snapshot);
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
    _debugProfileUpload(
      'firebase_user_exists=${user != null}'
      '${user == null ? '' : ' firebase_uid=${user.uid}'}',
    );
    if (user == null) {
      throw const ProfileException('Sign in to update your profile photo.');
    }

    onProgress(0);
    final storagePath = profileImageStoragePath(user.uid);
    _debugProfileUpload(
      'operation=started bucket=$_bucketName path=$storagePath '
      'method=uploadBinary upsert=true content_type=image/jpeg',
    );
    String publicUrl;
    try {
      await _supabase.storage
          .from(_bucketName)
          .uploadBinary(
            storagePath,
            bytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );
      _debugProfileUpload(
        'operation=completed bucket=$_bucketName path=$storagePath',
      );
      publicUrl = _supabase.storage.from(_bucketName).getPublicUrl(storagePath);
    } on StorageException catch (error, stackTrace) {
      _debugProfileUpload(
        'exception_type=${error.runtimeType} '
        'http_status_code=${error.statusCode ?? 'unavailable'} '
        'supabase_error_code=${error.error ?? 'unavailable'} '
        'message=${error.message}',
      );
      _debugProfileUploadStack('Supabase Storage upload failed', stackTrace);
      throw _mapStorageException(error);
    } on FirebaseAuthException catch (error, stackTrace) {
      _debugProfileUpload(
        'exception_type=${error.runtimeType} firebase_error_code=${error.code} '
        'message=${error.message ?? 'unavailable'}',
      );
      _debugProfileUploadStack(
        'Firebase ID token retrieval failed during Storage upload',
        stackTrace,
      );
      throw const ProfileException(
        'Your sign-in expired. Please sign in again.',
      );
    } catch (error, stackTrace) {
      _debugProfileUpload('exception_type=${error.runtimeType} message=$error');
      _debugProfileUploadStack('Storage upload failed', stackTrace);
      throw const ProfileException(
        'The profile photo could not be uploaded due to a network or server problem. Please try again.',
      );
    }

    try {
      final userSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      if (!userSnapshot.exists) {
        throw const ProfileException(
          'Your profile could not be found after the upload.',
        );
      }

      final profile = AppUserModel.fromFirestore(userSnapshot);
      final batch = _firestore.batch();
      final userRef = _firestore.collection('users').doc(user.uid);
      batch.update(userRef, {
        'profileImageUrl': publicUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (profile.role == UserRole.doctor) {
        final doctor = await _resolveOwnedDoctor(user.uid);
        if (doctor == null) {
          throw const ProfileException(
            'Your doctor profile could not be found. The photo was not saved.',
          );
        }
        batch.update(doctor.reference, {
          'profileImageUrl': publicUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      _debugProfileUpload(
        'firestore_profile_image_url_update=completed '
        'firebase_uid=${user.uid}',
      );
    } on ProfileException {
      rethrow;
    } on FirebaseException catch (error, stackTrace) {
      _debugProfileUpload(
        'firestore_profile_image_url_update=failed '
        'exception_type=${error.runtimeType} firebase_error_code=${error.code} '
        'message=${error.message ?? 'unavailable'}',
      );
      _debugProfileUploadStack(
        'Firestore profile image update failed',
        stackTrace,
      );
      throw ProfileException(
        error.code == 'permission-denied'
            ? 'You do not have permission to update this profile photo.'
            : 'The photo uploaded, but it could not be saved to your profile. Please try again.',
      );
    } catch (error, stackTrace) {
      _debugProfileUpload(
        'firestore_profile_image_url_update=failed '
        'exception_type=${error.runtimeType} message=$error',
      );
      _debugProfileUploadStack(
        'Firestore profile image update failed',
        stackTrace,
      );
      throw const ProfileException(
        'The photo uploaded, but it could not be saved to your profile. Please try again.',
      );
    }

    onProgress(1);
    return getCurrentProfile();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> _resolveOwnedDoctor(
    String uid,
  ) async {
    final matches = await _firestore
        .collection('doctors')
        .where('uid', isEqualTo: uid)
        .limit(2)
        .get();
    if (matches.docs.length > 1) return null;
    if (matches.docs.isNotEmpty) return matches.docs.single;

    final direct = await _firestore.collection('doctors').doc(uid).get();
    if (!_ownsDoctorProfile(direct, uid)) return null;
    return direct;
  }

  bool _ownsDoctorProfile(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    String uid,
  ) {
    final data = snapshot.data();
    if (data == null) return false;
    final ownerUid = data['uid'];
    return ownerUid is! String || ownerUid.trim().isEmpty
        ? snapshot.id == uid
        : ownerUid == uid;
  }

  ProfileException _mapStorageException(StorageException error) {
    final status = error.statusCode;
    if (status == '404' ||
        error.message.toLowerCase().contains('bucket not found')) {
      return const ProfileException(
        'Profile photo storage is not configured. Please contact support.',
      );
    }
    if (status == '401' || status == '403') {
      return const ProfileException(
        'You do not have permission to upload a profile photo.',
      );
    }
    if (error.message.toLowerCase().contains('expired')) {
      return const ProfileException(
        'Your sign-in expired. Please sign in again.',
      );
    }
    return const ProfileException(
      'The profile photo could not be uploaded. Please try again.',
    );
  }
}

String profileImageStoragePath(String firebaseUid) =>
    'users/$firebaseUid/profile.jpg';

void _debugProfileUpload(String message) {
  if (kDebugMode) debugPrint('[ProfileImageUpload] $message');
}

void _debugProfileUploadStack(String label, StackTrace stackTrace) {
  if (kDebugMode) {
    debugPrintStack(
      label: '[ProfileImageUpload] $label',
      stackTrace: stackTrace,
    );
  }
}
