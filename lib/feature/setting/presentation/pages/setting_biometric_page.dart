import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/theme/app_nyt_color.dart';
import 'package:news_app/core/theme/theme_manager.dart';
import 'package:news_app/feature/setting/presentation/bloc/devive_management_bloc/device_management_bloc.dart';
import 'package:news_app/gen/assets.gen.dart';
import 'package:news_app/generated/locales.g.dart';
import 'package:packages/widget/app_bar/app_bar_widget.dart';
import 'package:packages/widget/button/icon_button_widget.dart';
import 'package:packages/widget/divider_widget/divider_widget.dart';
import 'package:packages/widget/layout/layout.dart';
import 'package:packages/widget/switch_widget/switch_widget.dart';

class SettingBiometricPage extends StatefulWidget {
  const SettingBiometricPage({super.key});

  @override
  State<SettingBiometricPage> createState() => _SettingBiometricPageState();
}

class _SettingBiometricPageState extends State<SettingBiometricPage> {
  late DeviceManagementBloc _deviceBloc;
  bool isBiometricEnabled = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _deviceBloc = DeviceManagementBloc();
    _deviceBloc.add(const GetDeviceByIdentifierEvent());
  }

  @override
  void dispose() {
    _deviceBloc.close();
    super.dispose();
  }

  void _handleBiometricToggle(bool value) {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    _deviceBloc.add(UpdateBiometricEvent(isBiometric: value));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _deviceBloc,
      child: BlocConsumer<DeviceManagementBloc, DeviceManagementState>(
        listener: (context, state) {
          if (state is DeviceManagementDeviceFound) {
            setState(() {
              isBiometricEnabled = state.device.isBiometric == true;
              isLoading = false;
            });
          } else if (state is DeviceManagementDeviceNotFound) {
            setState(() {
              isBiometricEnabled = false;
              isLoading = false;
            });
          } else if (state is DeviceManagementBiometricUpdated) {
            setState(() {
              isLoading = false;
            });
            _deviceBloc.add(const GetDeviceByIdentifierEvent());
          } else if (state is DeviceManagementError) {
            setState(() {
              isLoading = false;
            });

            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.failure.message), backgroundColor: Colors.red),
            );

            // Reload to get actual state from server
            _deviceBloc.add(const GetDeviceByIdentifierEvent());
          } else if (state is DeviceManagementUpdatingBiometric) {
            setState(() {
              isLoading = true;
            });
          }
        },
        builder: (context, state) {
          return LayoutWidget(
            appBar: AppBarWidget(
              backgroundColor: AppThemeManager.appBar.withValues(alpha: 0.8),
              boxShadow: BoxShadow(
                color: AppThemeManager.shadow,
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
              paddingTop: 0,
              paddingBottom: 0,
              overlayColor: true,
              leading: IconButtonWidget(
                onPressed: () => Navigator.pop(context),
                svgPath: $AssetsIconsFilledGen().backward,
                color: AppThemeManager.icon,
                padding: const EdgeInsets.all(12.0),
              ),
              title: Text(
                LocaleKeys.setting_data_usage_title.tr,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontFamily: 'Roboto'),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),
                  DividerWidget(color: AppThemeManager.divider),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            LocaleKeys.setting_biometric_login_with_biometric.trArgs(['Face ID']),
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(fontFamily: 'Roboto'),
                          ),
                        ),
                        // Use a Stack to overlay loading indicator
                        SwitchWidget(
                          key: ValueKey('biometric_switch_${isBiometricEnabled}_$isLoading'),
                          initialValue: isBiometricEnabled,
                          inactiveThumbColor: AppNYTColors.lightBackground,
                          onChanged:
                              isLoading ? null : _handleBiometricToggle, // Disable when loading
                        ),
                      ],
                    ),
                  ),
                  DividerWidget(color: AppThemeManager.divider),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                    child: Text(
                      LocaleKeys.setting_biometric_login_with_biometric_desc.trArgs(['Face ID']),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        color: AppThemeManager.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  DividerWidget(color: AppThemeManager.divider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
