// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dartz/dartz.dart';
import 'package:news_app/core/base/error/failures.dart';
import 'package:news_app/core/global/device/data/data_source/device_remote_data_source.dart';
import 'package:news_app/core/global/device/data/model/device_model.dart';
import 'package:news_app/core/global/device/domain/entities/device.dart';
import 'package:news_app/core/global/device/domain/repository/device_repository.dart';
import 'package:news_app/core/service/secure/secure_token_manager.dart';
import 'package:packages/core/service/logger_service.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceRemoteDataSource deviceRemoteDataSource;

  DeviceRepositoryImpl({required this.deviceRemoteDataSource});

  @override
  Future<Either<Failure, bool>> createDevice({required DeviceModel device}) async {
    try {
      // final DeviceInfoService deviceInfoService = DeviceInfoService.instance;
      // final Map<String, dynamic>? deviceInfo = await deviceInfoService.getApiDeviceInfo();

      final result = await deviceRemoteDataSource.createDevice(
        deviceModel: device,
      );

      return result.fold(
        (failure) {
          printE('[DeviceRepositoryImpl] Create device failed: ${failure.message}');
          return Left(failure);
        },
        (isSuccess) {
          printS('[DeviceRepositoryImpl] Create device data saved successfully');
          return Right(isSuccess);
        },
      );
    } catch (e) {
      printE('[DeviceRepositoryImpl] Unexpected error during create device: $e');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateBiometric({
    required String userId,
    required bool isBiometric,
    required String deviceIdentifier,
    required String typeBiometric,
  }) async {
    try {
      final result = await deviceRemoteDataSource.updateBiometric(
        userId: userId,
        isBiometric: isBiometric,
        deviceIdentifier: deviceIdentifier,
        typeBiometric: typeBiometric,
      );

      return result.fold(
        (failure) {
          printE('[DeviceRepositoryImpl] Create device failed: ${failure.message}');
          return Left(failure);
        },
        (data) {
          printS('[DeviceRepositoryImpl] Create device data saved successfully');
          return Right(data);
        },
      );
    } catch (e) {
      printE('[DeviceRepositoryImpl] Unexpected error during create device: $e');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Device>>> getListDevice() async {
    try {
      final secureStore = await SecureTokenManager.getInstance();
      final userData = await secureStore.getUserData();
      final result = await deviceRemoteDataSource.getListDevice(userId: userData?.userId ?? '');

      return result.fold(
        (failure) {
          printE('[DeviceRepositoryImpl] Get list device failed: ${failure.message}');
          return Left(failure);
        },
        (result) {
          printS('[DeviceRepositoryImpl] Get list device data saved successfully');
          final devices = result.map<Device>((model) => model.toEntity()).toList();
          return Right(devices);
        },
      );
    } catch (e) {
      printE('[DeviceRepositoryImpl] Unexpected error during get list device: $e');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Device>> getDeviceByIdentifierAndUserId({
    required String deviceIdentifier,
    required String userId,
  }) async {
    try {
      final result = await deviceRemoteDataSource.getDeviceByIdentifierAndUserId(
        deviceIdentifier: deviceIdentifier,
        userId: userId,
      );

      return result.fold(
        (failure) {
          printE('[DeviceRepositoryImpl] Get device by identifier failed: ${failure.message}');
          return Left(failure);
        },
        (deviceModel) {
          printS('[DeviceRepositoryImpl] Get device by identifier successful');
          final device = deviceModel.toEntity();
          return Right(device);
        },
      );
    } catch (e) {
      printE('[DeviceRepositoryImpl] Unexpected error during get device by identifier: $e');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteDevice({required String deviceId}) async {
    try {
      final result = await deviceRemoteDataSource.deleteDevice(deviceId: deviceId);

      return result.fold(
        (failure) {
          printE('[DeviceRepositoryImpl] Delete device failed: ${failure.message}');
          return Left(failure);
        },
        (isSuccess) {
          printS('[DeviceRepositoryImpl] Delete device data saved successfully');
          return Right(isSuccess);
        },
      );
    } catch (e) {
      printE('[DeviceRepositoryImpl] Unexpected error during delete device: $e');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
