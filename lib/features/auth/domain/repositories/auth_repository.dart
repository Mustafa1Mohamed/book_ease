import '../entities/app_user.dart';

abstract interface class AuthRepository {
  Stream<AppUser?> authStateChanges();

  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AppUser> signUpWithEmail({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  });

  Future<AppUser> signInWithGoogle();

  Future<void> sendPasswordResetEmail(String email);

  Future<AppUser?> getProfile(String uid);

  Future<AppUser> completeProfile({
    required String fullName,
    required String phoneNumber,
  });

  Future<void> signOut();
}
