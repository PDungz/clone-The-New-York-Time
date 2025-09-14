// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dartz/dartz.dart';
import 'package:news_app/core/base/error/failures.dart';
import 'package:news_app/feature/auth/domain/entities/User.dart';
import 'package:news_app/feature/auth/domain/repository/auth_repository.dart';

class AuthUseCase {
  final AuthRepository authRepository;

  AuthUseCase({required this.authRepository});

  Future<Either<Failure, User>> login({required String username, required String password}) async {
    return await authRepository.login(username: username, password: password);
  }

  Future<Either<Failure, bool>> logout() async {
    return await authRepository.logout();
  }

  Future<Either<Failure, bool>> refreshToken({required String refreshToken}) async {
    return await authRepository.refreshToken(refreshToken: refreshToken);
  }

  Future<Either<Failure, User>> biometricLogin({
    required String email,
    required bool isBiometric,
    required String deviceIdentifier,
    required String typeBiometric,
  }) async {
    return await authRepository.biometricLogin(
      email: email,
      deviceIdentifier: deviceIdentifier,
      isBiometric: isBiometric,
      typeBiometric: typeBiometric,
    );
  }
}
