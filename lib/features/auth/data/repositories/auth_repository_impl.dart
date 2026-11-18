import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Stream<AppUser?> authStateChanges() => _remoteDataSource.authStateChanges();

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) => _remoteDataSource.signInWithEmail(email: email, password: password);

  @override
  Future<AppUser> signUpWithEmail({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) => _remoteDataSource.signUpWithEmail(
    fullName: fullName,
    email: email,
    phoneNumber: phoneNumber,
    password: password,
  );

  @override
  Future<AppUser> signInWithGoogle() => _remoteDataSource.signInWithGoogle();

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _remoteDataSource.sendPasswordResetEmail(email);

  @override
  Future<AppUser?> getProfile(String uid) => _remoteDataSource.getProfile(uid);

  @override
  Future<AppUser> completeProfile({
    required String fullName,
    required String phoneNumber,
  }) => _remoteDataSource.completeProfile(
    fullName: fullName,
    phoneNumber: phoneNumber,
  );

  @override
  Future<void> signOut() => _remoteDataSource.signOut();
}
