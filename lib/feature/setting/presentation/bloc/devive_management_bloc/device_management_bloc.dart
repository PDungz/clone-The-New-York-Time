import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:news_app/core/base/error/failures.dart';
import 'package:news_app/core/global/device/data/model/device_model.dart';
import 'package:news_app/core/global/device/domain/entities/device.dart';
import 'package:news_app/core/global/device/domain/enum/device_type_enum.dart';
import 'package:news_app/core/global/device/domain/use_case/device_use_case.dart';
import 'package:news_app/core/service/device/biometric/biometric_service.dart';
import 'package:news_app/core/service/device/device_info/device_info_service.dart';
import 'package:news_app/core/service/di/injection_container.dart';
import 'package:news_app/core/service/secure/secure_token_manager.dart';
import 'package:packages/core/service/logger_service.dart';

part 'device_management_event.dart';
part 'device_management_state.dart';

class DeviceManagementBloc extends Bloc<DeviceManagementEvent, DeviceManagementState> {
  final DeviceUseCase deviceUseCase = getIt<DeviceUseCase>();

  DeviceManagementBloc() : super(DeviceManagementInitial()) {
    on<LoadDevicesEvent>(_onLoadDevices);
    on<CreateDeviceEvent>(_onCreateDevice);
    on<DeleteDeviceEvent>(_onDeleteDevice);
    on<UpdateBiometricEvent>(_onUpdateBiometric);
    on<GetDeviceByIdentifierEvent>(_onGetDeviceByIdentifier);
  }

  Future<void> _onLoadDevices(LoadDevicesEvent event, Emitter<DeviceManagementState> emit) async {
    try {
      emit(DeviceManagementLoading());
      printI('[DeviceManagementBloc] Loading devices...');

      final result = await deviceUseCase.getListDevice();

      result.fold(
        (failure) {
          printE('[DeviceManagementBloc] Failed to load devices: ${failure.message}');
          emit(DeviceManagementError(failure: failure, context: 'Loading devices'));
        },
        (devices) {
          printS('[DeviceManagementBloc] Successfully loaded ${devices.length} devices');

          final List<Device> devicesMobile =
              devices.where((device) => device.deviceType == DeviceType.MOBILE.name).toList();
          final List<Device> devicesTable =
              devices.where((device) => device.deviceType == DeviceType.TABLET.name).toList();
          final List<Device> devicesDesktop =
              devices.where((device) => device.deviceType == DeviceType.DESKTOP.name).toList();

          emit(
            DeviceManagementLoaded(
              devicesMobile: devicesMobile,
              devicesTable: devicesTable,
              devicesDesktop: devicesDesktop,
              allDevices: devices,
            ),
          );
        },
      );
    } catch (e) {
      printE('[DeviceManagementBloc] Unexpected error loading devices: $e');
      emit(
        DeviceManagementError(
          failure: ServerFailure('Unexpected error: $e'),
          context: 'Loading devices',
        ),
      );
    }
  }

  Future<void> _onCreateDevice(CreateDeviceEvent event, Emitter<DeviceManagementState> emit) async {
    try {
      emit(DeviceManagementCreating());
      printI('[DeviceManagementBloc] Creating device...');

      final result = await deviceUseCase.createDevice(device: event.deviceModel);

      result.fold(
        (failure) {
          printE('[DeviceManagementBloc] Failed to create device: ${failure.message}');
          emit(DeviceManagementError(failure: failure, context: 'Creating device'));
        },
        (success) {
          if (success) {
            printS('[DeviceManagementBloc] Device created successfully');
            emit(const DeviceManagementCreated());
            // Reload devices to get updated list
            add(const LoadDevicesEvent());
          } else {
            printE('[DeviceManagementBloc] Device creation returned false');
            emit(
              DeviceManagementError(
                failure: ServerFailure('Failed to create device'),
                context: 'Creating device',
              ),
            );
          }
        },
      );
    } catch (e) {
      printE('[DeviceManagementBloc] Unexpected error creating device: $e');
      emit(
        DeviceManagementError(
          failure: ServerFailure('Unexpected error: $e'),
          context: 'Creating device',
        ),
      );
    }
  }

  Future<void> _onDeleteDevice(DeleteDeviceEvent event, Emitter<DeviceManagementState> emit) async {
    try {
      emit(DeviceManagementDeleting());
      printI('[DeviceManagementBloc] Deleting device with ID: ${event.deviceId}');

      final result = await deviceUseCase.deleteDevice(deviceId: event.deviceId);

      result.fold(
        (failure) {
          printE('[DeviceManagementBloc] Failed to delete device: ${failure.message}');
          emit(DeviceManagementError(failure: failure, context: 'Deleting device'));
        },
        (success) {
          if (success) {
            printS('[DeviceManagementBloc] Device deleted successfully');
            emit(const DeviceManagementDeleted());
            // Reload devices to get updated list
            add(const LoadDevicesEvent());
          } else {
            printE('[DeviceManagementBloc] Device deletion returned false');
            emit(
              DeviceManagementError(
                failure: ServerFailure('Failed to delete device'),
                context: 'Deleting device',
              ),
            );
          }
        },
      );
    } catch (e) {
      printE('[DeviceManagementBloc] Unexpected error deleting device: $e');
      emit(
        DeviceManagementError(
          failure: ServerFailure('Unexpected error: $e'),
          context: 'Deleting device',
        ),
      );
    }
  }

  Future<void> _onUpdateBiometric(
    UpdateBiometricEvent event,
    Emitter<DeviceManagementState> emit,
  ) async {
    try {
      emit(DeviceManagementUpdatingBiometric());
    
      // Get device info
      final DeviceInfoService deviceInfoService = DeviceInfoService.instance;
      final Map<String, dynamic>? deviceInfo = await deviceInfoService.getApiDeviceInfo();
      final secureStore = await SecureTokenManager.getInstance();
      final userData = await secureStore.getUserData();
    
      // Create device model with FCM token
      final deviceModel = DeviceModel.fromJson(deviceInfo ?? <String, dynamic>{}).copyWith();
      final biometricInfo = await BiometricService.I.biometric;

      printI(
        '[DeviceManagementBloc] Updating biometric settings for device: ${deviceModel.deviceIdentifier}',
      );
    
      bool setUpBiometric = false;
    
      if (event.isBiometric) {
        // User wants to enable biometric - authenticate first
        final biometricResult = await BiometricService.I.authenticate(
          localizedReason: biometricInfo.typeName,
          autoDetectMessage: true,
        );
      
        if (!biometricResult.success) {
          // Authentication failed - emit error and return
          printE('[DeviceManagementBloc] Biometric authentication failed');
          emit(
            DeviceManagementError(
              failure: ServerFailure('Biometric authentication failed or cancelled'),
              context: 'Biometric authentication',
            ),
          );
          return;
        }

        setUpBiometric = true;
      } else {
        // User wants to disable biometric - no authentication needed
        setUpBiometric = false;
      }

      final result = await deviceUseCase.updateBiometric(
        userId: userData?.userId ?? '',
        isBiometric: setUpBiometric,
        deviceIdentifier: deviceModel.deviceIdentifier ?? '',
        typeBiometric: biometricInfo.primaryType.name,
      );

      result.fold(
        (failure) {
          printE('[DeviceManagementBloc] Failed to update biometric: ${failure.message}');
          emit(DeviceManagementError(failure: failure, context: 'Updating biometric'));
        },
        (success) {
          if (success) {
            printS('[DeviceManagementBloc] Biometric settings updated successfully');
            emit(const DeviceManagementBiometricUpdated());
            // Note: Don't add LoadDevicesEvent here, let the UI handle reloading
          } else {
            printE('[DeviceManagementBloc] Biometric update returned false');
            emit(
              DeviceManagementError(
                failure: ServerFailure('Failed to update biometric settings'),
                context: 'Updating biometric',
              ),
            );
          }
        },
      );
    } catch (e) {
      printE('[DeviceManagementBloc] Unexpected error updating biometric: $e');
      emit(
        DeviceManagementError(
          failure: ServerFailure('Unexpected error: $e'),
          context: 'Updating biometric',
        ),
      );
    }
  }

  Future<void> _onGetDeviceByIdentifier(
    GetDeviceByIdentifierEvent event,
    Emitter<DeviceManagementState> emit,
  ) async {
    try {
      emit(DeviceManagementGettingDevice());
      final DeviceInfoService deviceInfoService = DeviceInfoService.instance;
      final Map<String, dynamic>? deviceInfo = await deviceInfoService.getApiDeviceInfo();
      final secureStore = await SecureTokenManager.getInstance();
      final userData = await secureStore.getUserData();
      // Create device model with FCM token
      final deviceModel = DeviceModel.fromJson(deviceInfo ?? <String, dynamic>{}).copyWith();

      printI(
        '[DeviceManagementBloc] Getting device by identifier: ${deviceModel.deviceIdentifier}',
      );

      final result = await deviceUseCase.getDeviceByIdentifierAndUserId(
        deviceIdentifier: deviceModel.deviceIdentifier ?? '',
        userId: userData?.userId ?? '',
      );

      result.fold(
        (failure) {
          printE('[DeviceManagementBloc] Failed to get device: ${failure.message}');
          // Check if it's a "not found" type error
          if (failure.message.toLowerCase().contains('not found') ||
              failure.message.toLowerCase().contains('no device')) {
            emit(const DeviceManagementDeviceNotFound());
          } else {
            emit(DeviceManagementError(failure: failure, context: 'Getting device'));
          }
        },
        (device) {
          printS('[DeviceManagementBloc] Device found successfully');
          emit(DeviceManagementDeviceFound(device: device));
        },
      );
    } catch (e) {
      printE('[DeviceManagementBloc] Unexpected error getting device: $e');
      emit(
        DeviceManagementError(
          failure: ServerFailure('Unexpected error: $e'),
          context: 'Getting device',
        ),
      );
    }
  }

  // Helper method to get current devices from state
  List<Device> get currentDevices {
    final currentState = state;
    if (currentState is DeviceManagementLoaded) {
      return currentState.allDevices;
    }
    return [];
  }

  // Helper method to check if a device exists locally
  Device? findDeviceById(String deviceId) {
    return currentDevices.firstWhere(
      (device) => device.id == deviceId,
      // ignore: cast_from_null_always_fails
      orElse: () => null as Device,
    );
  }

  // Helper method to get devices by type
  List<Device> getDevicesByType(DeviceType deviceType) {
    return currentDevices.where((device) => device.deviceType == deviceType.name).toList();
  }
}
