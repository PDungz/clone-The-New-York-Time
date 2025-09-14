part of 'device_management_bloc.dart';

sealed class DeviceManagementEvent extends Equatable {
  const DeviceManagementEvent();

  @override
  List<Object> get props => [];
}

class LoadDevicesEvent extends DeviceManagementEvent {
  const LoadDevicesEvent();
}

class CreateDeviceEvent extends DeviceManagementEvent {
  final DeviceModel deviceModel;

  const CreateDeviceEvent({required this.deviceModel});

  @override
  List<Object> get props => [deviceModel];
}

class DeleteDeviceEvent extends DeviceManagementEvent {
  final String deviceId;

  const DeleteDeviceEvent({required this.deviceId});

  @override
  List<Object> get props => [deviceId];
}

class UpdateBiometricEvent extends DeviceManagementEvent {
  final bool isBiometric;

  const UpdateBiometricEvent({required this.isBiometric});

  @override
  List<Object> get props => [isBiometric];
}

class GetDeviceByIdentifierEvent extends DeviceManagementEvent {
  const GetDeviceByIdentifierEvent();

  @override
  List<Object> get props => [];
}
