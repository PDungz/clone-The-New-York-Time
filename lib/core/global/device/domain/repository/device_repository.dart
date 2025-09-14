import 'package:dartz/dartz.dart';
import 'package:news_app/core/base/error/failures.dart';
import 'package:news_app/core/global/device/data/model/device_model.dart';
import 'package:news_app/core/global/device/domain/entities/device.dart';

abstract class DeviceRepository {
  Future<Either<Failure, bool>> createDevice({required DeviceModel device});
  Future<Either<Failure, List<Device>>> getListDevice();
  Future<Either<Failure, Device>> getDeviceByIdentifierAndUserId({
    required String deviceIdentifier,
    required String userId,
  });
  Future<Either<Failure, bool>> deleteDevice({required String deviceId});
  Future<Either<Failure, bool>> updateBiometric({
    required String userId,
    required bool isBiometric,
    required String deviceIdentifier,
    required String typeBiometric,
  });
}
