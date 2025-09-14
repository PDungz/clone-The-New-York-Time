import 'package:dartz/dartz.dart';
import 'package:news_app/core/base/error/failures.dart';
import 'package:news_app/feature/auth/domain/entities/User.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({required String username, required String password});
  Future<Either<Failure, User>> biometricLogin({
    required String email,
    required bool isBiometric,
    required String deviceIdentifier,
    required String typeBiometric,
  });
  Future<Either<Failure, bool>> logout();
  Future<Either<Failure, bool>> refreshToken({required String refreshToken});
}
