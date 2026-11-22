import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required this._repository, required this._firebaseAuth})
    : super(const AuthInitial()) {
    _authSubscription = _repository.authStateChanges().listen(
      _handleAuthChange,
      onError: (Object _) {
        emit(const AuthError('We could not restore your session.'));
      },
    );
  }

  final AuthRepository _repository;
  final FirebaseAuth _firebaseAuth;
  StreamSubscription? _authSubscription;
  bool _isSubmitting = false;

  Future<void> checkSession() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        emit(const AuthUnauthenticated());
        return;
      }

      final profile = await _repository.getProfile(firebaseUser.uid);
      if (profile == null) {
        emit(AuthProfileIncomplete(firebaseUser.email ?? ''));
      } else {
        _emitProfile(profile);
      }
    } on FirebaseException catch (error) {
      emit(AuthError(_firebaseAuthMessage(error)));
    } catch (_) {
      emit(const AuthError('We could not restore your session.'));
    }
  }

  void _handleAuthChange(AppUser? profile) {
    if (profile == null) {
      if (_firebaseAuth.currentUser == null) {
        emit(const AuthUnauthenticated());
      } else {
        emit(AuthProfileIncomplete(_firebaseAuth.currentUser?.email ?? ''));
      }
    } else {
      _emitProfile(profile);
    }
  }

  void _emitProfile(AppUser profile) {
    if (profile.role == UserRole.patient && !profile.isComplete) {
      emit(AuthProfileIncomplete(profile.email));
    } else {
      emit(AuthAuthenticated(profile));
    }
  }

  Future<void> signIn(String email, String password) async {
    if (_isSubmitting) return;
    _isSubmitting = true;
    emit(const AuthLoading());
    try {
      final user = await _repository.signInWithEmail(
        email: email,
        password: password,
      );
      _emitProfile(user);
    } on FirebaseAuthException catch (error) {
      emit(AuthError(_firebaseAuthMessage(error)));
    } on FirebaseException catch (error) {
      if (error.code == 'profile-missing') {
        emit(AuthProfileIncomplete(email));
      } else {
        emit(AuthError(_firebaseAuthMessage(error)));
      }
    } catch (_) {
      emit(const AuthError('Unable to sign in. Please try again.'));
    } finally {
      _isSubmitting = false;
    }
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    if (_isSubmitting) return;
    _isSubmitting = true;
    emit(const AuthLoading());
    try {
      final user = await _repository.signUpWithEmail(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );
      _emitProfile(user);
    } on FirebaseAuthException catch (error) {
      emit(AuthError(_firebaseAuthMessage(error)));
    } on FirebaseException catch (error) {
      emit(
        AuthError(
          error.code == 'supabase-role-claim-pending'
              ? 'Your account was created, but secure storage access is still being set up. Please sign out and sign in again shortly.'
              : 'Your account was created, but profile setup failed. Please sign in and retry.',
        ),
      );
    } catch (_) {
      emit(const AuthError('Unable to create your account. Please try again.'));
    } finally {
      _isSubmitting = false;
    }
  }

  Future<void> signInWithGoogle() async {
    if (_isSubmitting) return;
    _isSubmitting = true;
    emit(const AuthLoading());
    try {
      final user = await _repository.signInWithGoogle();
      _emitProfile(user);
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        emit(const AuthUnauthenticated());
      } else {
        emit(
          const AuthError(
            'Google Sign-In could not be completed. Check your configuration and try again.',
          ),
        );
      }
    } on FirebaseAuthException catch (error) {
      emit(AuthError(_firebaseAuthMessage(error)));
    } on FirebaseException catch (error) {
      emit(
        AuthError(
          error.code == 'supabase-role-claim-pending'
              ? 'Your account was created, but secure storage access is still being set up. Please sign out and sign in again shortly.'
              : 'Google Sign-In could not be completed. Please try again.',
        ),
      );
    } catch (_) {
      emit(
        const AuthError(
          'Google Sign-In could not be completed. Please try again.',
        ),
      );
    } finally {
      _isSubmitting = false;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    if (_isSubmitting) return;
    _isSubmitting = true;
    emit(const AuthLoading());
    try {
      await _repository.sendPasswordResetEmail(email);
      emit(AuthPasswordResetSent(email.trim()));
    } on FirebaseAuthException catch (error) {
      emit(AuthError(_firebaseAuthMessage(error)));
    } catch (_) {
      emit(
        const AuthError('Unable to send the reset email. Please try again.'),
      );
    } finally {
      _isSubmitting = false;
    }
  }

  Future<void> completeProfile({
    required String fullName,
    required String phoneNumber,
  }) async {
    if (_isSubmitting) return;
    _isSubmitting = true;
    emit(const AuthLoading());
    try {
      final user = await _repository.completeProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
      );
      _emitProfile(user);
    } catch (_) {
      emit(
        const AuthError('Unable to complete your profile. Please try again.'),
      );
    } finally {
      _isSubmitting = false;
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    emit(const AuthUnauthenticated());
  }

  String _firebaseAuthMessage(FirebaseException error) {
    switch (error.code) {
      case 'invalid-email':
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'The email or password is incorrect.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'Choose a stronger password.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Authentication could not be completed. Please try again.';
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
