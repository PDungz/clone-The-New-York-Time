part of 'device_management_bloc.dart';

sealed class DeviceManagementState extends Equatable {
  const DeviceManagementState();
  
  @override
  List<Object?> get props => [];
}

final class DeviceManagementInitial extends DeviceManagementState {}

final class DeviceManagementLoading extends DeviceManagementState {}

final class DeviceManagementLoaded extends DeviceManagementState {
  final List<Device> devicesMobile;
  final List<Device> devicesTable;
  final List<Device> devicesDesktop;
  final List<Device> allDevices;

  const DeviceManagementLoaded({
    required this.devicesMobile,
    required this.devicesTable,
    required this.devicesDesktop,
    required this.allDevices,
  });

  @override
  List<Object> get props => [devicesMobile, devicesTable, devicesDesktop, allDevices];
}

// Create Device States
final class DeviceManagementCreating extends DeviceManagementState {}

final class DeviceManagementCreated extends DeviceManagementState {
  final String message;

  const DeviceManagementCreated({this.message = 'Device created successfully'});

  @override
  List<Object> get props => [message];
}

// Delete Device States
final class DeviceManagementDeleting extends DeviceManagementState {}

final class DeviceManagementDeleted extends DeviceManagementState {
  final String message;

  const DeviceManagementDeleted({this.message = 'Device deleted successfully'});

  @override
  List<Object> get props => [message];
}

// Update Biometric States
final class DeviceManagementUpdatingBiometric extends DeviceManagementState {}

final class DeviceManagementBiometricUpdated extends DeviceManagementState {
  final String message;

  const DeviceManagementBiometricUpdated({this.message = 'Biometric settings updated successfully'});

  @override
  List<Object> get props => [message];
}

// Get Device by Identifier States
final class DeviceManagementGettingDevice extends DeviceManagementState {}

final class DeviceManagementDeviceFound extends DeviceManagementState {
  final Device device;

  const DeviceManagementDeviceFound({required this.device});

  @override
  List<Object> get props => [device];
}

final class DeviceManagementDeviceNotFound extends DeviceManagementState {
  final String message;

  const DeviceManagementDeviceNotFound({this.message = 'Device not found'});

  @override
  List<Object> get props => [message];
}

// Error State
final class DeviceManagementError extends DeviceManagementState {
  final Failure failure;
  final String? context; // Additional context about which operation failed

  const DeviceManagementError({
    required this.failure,
    this.context,
  });

  @override
  List<Object?> get props => [failure, context];
}