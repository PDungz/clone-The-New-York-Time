import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:news_app/core/global/device/domain/entities/device.dart';
import 'package:news_app/core/theme/app_dimension.dart';
import 'package:news_app/core/theme/theme_manager.dart';
import 'package:news_app/feature/setting/presentation/bloc/devive_management_bloc/device_management_bloc.dart';
import 'package:news_app/feature/setting/presentation/widget/setting_device_manager_widget.dart';
import 'package:news_app/gen/assets.gen.dart';
import 'package:news_app/generated/locales.g.dart';
import 'package:packages/widget/app_bar/app_bar_widget.dart';
import 'package:packages/widget/button/icon_button_widget.dart';
import 'package:packages/widget/layout/layout.dart';

class SettingDeviceManager extends StatefulWidget {
  const SettingDeviceManager({super.key});

  @override
  State<SettingDeviceManager> createState() => _SettingDeviceManagerState();
}

class _SettingDeviceManagerState extends State<SettingDeviceManager> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DeviceManagementBloc()..add(LoadDevicesEvent()),
      child: BlocListener<DeviceManagementBloc, DeviceManagementState>(
        listener: (context, state) {
          // Xử lý các trạng thái thay đổi
          if (state is DeviceManagementCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Device created successfully'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is DeviceManagementDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Device deleted successfully'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is DeviceManagementError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.failure.toString()}'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 4),
              ),
            );
          }
        },
        child: BlocBuilder<DeviceManagementBloc, DeviceManagementState>(
          builder: (context, state) {
            return LayoutWidget(
              isLoadingOverlay:
                  (state is DeviceManagementLoading ||
                      state is DeviceManagementCreating ||
                      state is DeviceManagementDeleting),
              appBar: AppBarWidget(
                backgroundColor: AppThemeManager.appBar.withValues(alpha: AppDimensions.opacity80),
                boxShadow: BoxShadow(
                  color: AppThemeManager.shadow,
                  blurRadius: AppDimensions.radius4,
                  offset: const Offset(0, 1),
                ),
                paddingTop: AppDimensions.inset0,
                paddingBottom: AppDimensions.inset0,
                overlayColor: true,
                leading: IconButtonWidget(
                  onPressed: () => Navigator.pop(context),
                  svgPath: $AssetsIconsFilledGen().backward,
                  color: AppThemeManager.icon,
                  padding: EdgeInsets.all(AppDimensions.radius12),
                ),
                title: Text(
                  LocaleKeys.setting_device_manager_title.tr,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontFamily: 'Roboto'),
                ),
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.inset20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppDimensions.space72),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppThemeManager.warning.withValues(alpha: AppDimensions.opacity40),
                          borderRadius: BorderRadius.circular(AppDimensions.radius8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.inset12,
                            horizontal: AppDimensions.inset16,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    $AssetsIconsFilledGen().warning,
                                    width: AppDimensions.icon24,
                                    height: AppDimensions.icon24,
                                  ),
                                  const SizedBox(width: AppDimensions.space8),
                                  Text(
                                    LocaleKeys.setting_device_manager_notice_title.tr,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall?.copyWith(fontFamily: 'Roboto'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppDimensions.space8),
                              Text(
                                LocaleKeys.setting_device_manager_account_sharing_warning.tr,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontFamily: 'Roboto',
                                  fontSize: AppDimensions.font14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space20),
                      SettingDeviceManagerWidget(
                        titleDevice: LocaleKeys.setting_device_manager_mobile_app.tr,
                        devices: [if (state is DeviceManagementLoaded) ...state.devicesMobile],
                        deviceCount:
                            '${state is DeviceManagementLoaded ? state.devicesMobile.length : 0}/2',
                        onDeviceDelete: (device, index) {
                          _showDeleteConfirmation(context, device);
                        },
                        svgIconPath: $AssetsIconsFilledGen().phone,
                      ),
                      const SizedBox(height: AppDimensions.space20),
                      SettingDeviceManagerWidget(
                        titleDevice: LocaleKeys.setting_device_manager_website.tr,
                        devices: [if (state is DeviceManagementLoaded) ...state.devicesDesktop],
                        deviceCount:
                            '${state is DeviceManagementLoaded ? state.devicesDesktop.length : 0}/2',
                        onDeviceDelete: (device, index) {
                          _showDeleteConfirmation(context, device);
                        },
                        svgIconPath: $AssetsIconsFilledGen().laptop,
                      ),
                      const SizedBox(height: AppDimensions.space20),
                      SettingDeviceManagerWidget(
                        titleDevice: LocaleKeys.setting_device_manager_tablet.tr,
                        devices: [if (state is DeviceManagementLoaded) ...state.devicesTable],
                        deviceCount:
                            '${state is DeviceManagementLoaded ? state.devicesTable.length : 0}/1',
                        onDeviceDelete: (device, index) {
                          _showDeleteConfirmation(context, device);
                        },
                        svgIconPath: $AssetsIconsFilledGen().tablet,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Device device) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Delete Device'),
          content: Text('Are you sure you want to delete "${device.deviceName}"?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text('Cancel')),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Sử dụng context của widget cha để trigger delete event
                context.read<DeviceManagementBloc>().add(
                  DeleteDeviceEvent(deviceId: device.id ?? ''),
                );
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
