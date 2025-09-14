// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dartz/dartz.dart';
import 'package:news_app/core/base/api/api_service_v2.dart';
import 'package:news_app/core/base/api/model/api_response_v2.dart';
import 'package:news_app/core/base/config/app_config_manager_base.dart';
import 'package:news_app/core/base/error/failures.dart';
import 'package:news_app/core/global/device/data/model/device_model.dart';
import 'package:packages/core/service/logger_service.dart';

abstract class DeviceRemoteDataSource {
  Future<Either<Failure, bool>> createDevice({required DeviceModel deviceModel});
  Future<Either<Failure, List<DeviceModel>>> getListDevice({required String userId});
  Future<Either<Failure, DeviceModel>> getDeviceByIdentifierAndUserId({
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

class DeviceRemoteDataSourceImpl implements DeviceRemoteDataSource {
  final ApiServiceV2 _apiServiceV2;
  DeviceRemoteDataSourceImpl({required ApiServiceV2 apiServiceV2}) : _apiServiceV2 = apiServiceV2;

  @override
  Future<Either<Failure, bool>> createDevice({required DeviceModel deviceModel}) async {
    try {
      _apiServiceV2.updateBaseUrl(AppConfigManagerBase.apiBaseUrl);
      final ApiResponseV2<Map<String, dynamic>> response = await _apiServiceV2.post(
        AppConfigManagerBase.apiDeviceManagementCreate,
        data: deviceModel.toJson(),
      );
      if (response.statusCode == 200 && response.success) {
        printI('[Device DataSource] Device successful ');
        return Right(true);
      } else {
        printE('[Device DataSource]Device failed - invalid response structure');
        return Left(ServerFailure(response.message ?? 'Device failed'));
      }
    } catch (e) {
      printE('[Device DataSource] Exception: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DeviceModel>>> getListDevice({required String userId}) async {
    try {
      _apiServiceV2.updateBaseUrl(AppConfigManagerBase.apiBaseUrl);
      final ApiResponseV2<Map<String, dynamic>> response = await _apiServiceV2.get(
        AppConfigManagerBase.apiDeviceManagementListUser + userId,
        queryParameters: {"isActive": true, "status": "ACTIVE"},
      );
      if (response.statusCode == 200 && response.success) {
        printI('[Get List Device DataSource] Device successful ');
        // Assuming the list is under a key like 'devices' in the response data
        final List<dynamic> deviceListJson = (response.data?['data'] ?? []) as List<dynamic>;
        final List<DeviceModel> deviceList =
            deviceListJson
                .map((json) => DeviceModel.fromJson(json as Map<String, dynamic>))
                .toList();
        return Right(deviceList);
      } else {
        printE('[Get List Device DataSource]Device failed - invalid response structure');
        return Left(ServerFailure(response.message ?? 'Device failed'));
      }
    } catch (e) {
      printE('[Device DataSource] Exception: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DeviceModel>> getDeviceByIdentifierAndUserId({
    required String deviceIdentifier,
    required String userId,
  }) async {
    try {
      _apiServiceV2.updateBaseUrl(AppConfigManagerBase.apiBaseUrl);
      final ApiResponseV2<Map<String, dynamic>> response = await _apiServiceV2.get(
        AppConfigManagerBase.apiDeviceManagementInfoIndentifierUserId(
          deviceIdentifier: deviceIdentifier,
          userId: userId,
        ),
      );
      if (response.statusCode == 200 && response.success) {
        printI('[Get Device By Identifier DataSource] Device successful');

        // Check if data exists and is not null
        if (response.data?['data'] == null) {
          printE('[Get Device By Identifier DataSource] No device data found');
          return Left(ServerFailure('No device found'));
        }

        // Handle both single object and array responses
        final dynamic deviceData = response.data!['data'];
        DeviceModel device;

        if (deviceData is List) {
          if (deviceData.isEmpty) {
            printE('[Get Device By Identifier DataSource] Device list is empty');
            return Left(ServerFailure('No device found'));
          }
          // Take the first device from the list
          device = DeviceModel.fromJson(deviceData.first as Map<String, dynamic>);
        } else if (deviceData is Map<String, dynamic>) {
          // Handle single device object
          device = DeviceModel.fromJson(deviceData);
        } else {
          printE('[Get Device By Identifier DataSource] Invalid response data type');
          return Left(ServerFailure('Invalid response format'));
        }

        return Right(device);
      } else {
        printE('[Get Device By Identifier DataSource] Device failed - invalid response structure');
        return Left(ServerFailure(response.message ?? 'Device failed'));
      }
    } catch (e) {
      printE('[Get Device By Identifier DataSource] Exception: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteDevice({required String deviceId}) async {
    try {
      _apiServiceV2.updateBaseUrl(AppConfigManagerBase.apiBaseUrl);
      final ApiResponseV2<Map<String, dynamic>> response = await _apiServiceV2.delete(
        AppConfigManagerBase.apiDeviceManagementDelete + deviceId,
      );
      if (response.statusCode == 200 && response.success && response.data?['data'] != null) {
        printI('[Delete Device DataSource] Device successful ');
        return Right(true);
      } else {
        printE('[Delete Device DataSource]Device failed - invalid response structure');
        return Left(ServerFailure(response.message ?? 'Device failed'));
      }
    } catch (e) {
      printE('[Device DataSource] Exception: $e');
      return Left(ServerFailure(e.toString()));
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
      _apiServiceV2.updateBaseUrl(AppConfigManagerBase.apiBaseUrl);
      final ApiResponseV2<Map<String, dynamic>> response = await _apiServiceV2.post(
        AppConfigManagerBase.apiDeviceManagementUpdateBiometric,
        data: {
          "userId": userId,
          "isBiometric": isBiometric,
          "deviceIdentifier": deviceIdentifier,
          "typeBiometric": typeBiometric,
        },
      );
      if (response.statusCode == 200 && response.success && response.data?['data'] != null) {
        printI('[Get List Device DataSource] Device successful ');

        return Right(true);
      } else {
        printE('[Get List Device DataSource]Device failed - invalid response structure');
        return Left(ServerFailure(response.message ?? 'Device failed'));
      }
    } catch (e) {
      printE('[Device DataSource] Exception: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}
