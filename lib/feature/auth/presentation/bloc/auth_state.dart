part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state when bloc is created
final class AuthInitial extends AuthState {}

/// Loading state during authentication operations
final class AuthLoading extends AuthState {}

/// Authenticated state with user data
final class AuthAuthenticated extends AuthState {
  final User user;
  final bool isFromBiometric;

  const AuthAuthenticated({
    required this.user,
    this.isFromBiometric = false,
  });

  @override
  List<Object?> get props => [user, isFromBiometric];
}

/// Unauthenticated state
final class AuthUnauthenticated extends AuthState {}

/// Failure state with error information
final class AuthFailure extends AuthState {
  final String message;
  final String? errorCode;
  final bool isBiometricError;

  const AuthFailure({
    required this.message,
    this.errorCode,
    this.isBiometricError = false,
  });

  @override
  List<Object?> get props => [message, errorCode, isBiometricError];
}

/// Biometric available state
final class AuthBiometricAvailable extends AuthState {
  final Biometric biometricInfo;

  const AuthBiometricAvailable({
    required this.biometricInfo,
  });

  @override
  List<Object?> get props => [biometricInfo];
}