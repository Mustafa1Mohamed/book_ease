import 'package:equatable/equatable.dart';

import '../../domain/entities/app_user.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);

  final AppUser user;

  @override
  List<Object?> get props => [user];
}

class AuthProfileIncomplete extends AuthState {
  const AuthProfileIncomplete(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}

class AuthPasswordResetSent extends AuthState {
  const AuthPasswordResetSent(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}

class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
