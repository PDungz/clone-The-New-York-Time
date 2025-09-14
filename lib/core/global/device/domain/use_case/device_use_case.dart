// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dartz/dartz.dart';
import 'package:news_app/core/base/error/failures.dart';
import 'package:news_app/core/global/device/data/model/device_model.dart';
import 'package:news_app/core/global/device/domain/entities/device.dart';
import 'package:news_app/core/global/device/domain/repository/device_repository.dart';

class DeviceUseCase {
  final DeviceRepository deviceRepository;
  DeviceUseCase({required this.deviceRepository});

  Future<Either<Failure, bool>> createDevice({required DeviceModel device}) async {
    return await deviceRepository.createDevice(device: device);
  }

  Future<Either<Failure, List<Device>>> getListDevice() async {
    return await deviceRepository.getListDevice();
  }

  Future<Either<Failure, bool>> deleteDevice({required String deviceId}) async {
    return await deviceRepository.deleteDevice(deviceId: deviceId);
  }

  Future<Either<Failure, bool>> updateBiometric({
    required String userId,
    required bool isBiometric,
    required String deviceIdentifier,
    required String typeBiometric,
  }) async {
    return await deviceRepository.updateBiometric(
      userId: userId,
      isBiometric: isBiometric,
      deviceIdentifier: deviceIdentifier,
      typeBiometric: typeBiometric,
    );
  }

  Future<Either<Failure, Device>> getDeviceByIdentifierAndUserId({
    required String deviceIdentifier,
    required String userId,
  }) async {
    return await deviceRepository.getDeviceByIdentifierAndUserId(
      deviceIdentifier: deviceIdentifier,
      userId: userId,
    );
  }
}
