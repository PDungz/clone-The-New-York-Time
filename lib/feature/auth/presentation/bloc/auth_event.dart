// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event for login request
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  final bool rememberMe;

  const AuthLoginRequested({required this.email, required this.password, this.rememberMe = false});

  @override
  List<Object?> get props => [email, password, rememberMe];
}

/// Event for biometric authentication request
class AuthBiometricRequested extends AuthEvent {
  final String? localizedReason;
  final String? email;
  final bool? isBiometric;
  final String? deviceIdentifier;
  final String? typeBiometric;

  const AuthBiometricRequested({
    this.localizedReason,
    this.email,
    this.isBiometric,
    this.deviceIdentifier,
    this.typeBiometric,
  });

  @override
  List<Object?> get props => [localizedReason, email, deviceIdentifier, isBiometric, typeBiometric];

  AuthBiometricRequested copyWith({
    String? localizedReason,
    String? email,
    bool? isBiometric,
    String? deviceIdentifier,
    String? typeBiometric,
  }) {
    return AuthBiometricRequested(
      localizedReason: localizedReason ?? this.localizedReason,
      email: email ?? this.email,
      isBiometric: isBiometric ?? this.isBiometric,
      deviceIdentifier: deviceIdentifier ?? this.deviceIdentifier,
      typeBiometric: typeBiometric ?? this.typeBiometric,
    );
  }
}

/// Event for logout request
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Event to check authentication status
class AuthStatusRequested extends AuthEvent {
  const AuthStatusRequested();
}
