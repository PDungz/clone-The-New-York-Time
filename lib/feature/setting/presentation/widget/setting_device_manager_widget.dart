import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:news_app/core/global/device/domain/entities/device.dart';
import 'package:news_app/core/theme/app_dimension.dart';
import 'package:news_app/core/theme/theme_manager.dart';
import 'package:news_app/gen/assets.gen.dart';
import 'package:news_app/generated/locales.g.dart';
import 'package:packages/widget/button/icon_button_widget.dart';

class SettingDeviceManagerWidget extends StatelessWidget {
  const SettingDeviceManagerWidget({
    super.key,
    required this.titleDevice,
    required this.deviceCount,
    this.onDeviceDelete,
    this.svgIconPath,
    this.devices,
  });

  final String titleDevice;
  final List<Device>? devices;
  final String deviceCount;
  final Function(Device device, int index)? onDeviceDelete;
  final String? svgIconPath;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                titleDevice,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontFamily: 'Roboto'),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppThemeManager.border.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(AppDimensions.radius8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.inset2,
                  horizontal: AppDimensions.inset8,
                ),
                child: Text(
                  LocaleKeys.setting_device_manager_device_count.trArgs([
                    deviceCount,
                  ]),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontFamily: 'Roboto'),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (devices != null && devices!.isNotEmpty)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: devices?.length ?? 0,
            separatorBuilder:
                (context, index) =>
                    const SizedBox(height: AppDimensions.space12),
            itemBuilder: (context, index) {
              final device = devices![index];
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: AppThemeManager.border.withValues(
                    alpha: AppDimensions.opacity40,
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radius8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.inset12,
                    horizontal: AppDimensions.inset20,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: AppThemeManager.border,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusCircular,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(
                                  AppDimensions.inset12,
                                ),
                                child: SvgPicture.asset(
                                  svgIconPath ?? $AssetsIconsFilledGen().phone,
                                  width: AppDimensions.icon32,
                                  height: AppDimensions.icon32,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppDimensions.space8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    device.deviceName ?? '',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall?.copyWith(fontFamily: 'Roboto'),
                                  ),
                                  const SizedBox(height: AppDimensions.space4),
                                  Text(
                                    '${device.latestLocation?.city}${device.latestLocation?.country}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis, // Thêm dòng này
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.copyWith(fontFamily: 'Roboto'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButtonWidget(
                        svgPath: $AssetsIconsFilledGen().trash,
                        size: AppDimensions.icon28,
                        color: AppThemeManager.error,
                        onPressed:
                            onDeviceDelete != null
                                ? () => onDeviceDelete!(device, index)
                                : null,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        if (devices == null || devices!.isEmpty)
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppThemeManager.border.withValues(
                alpha: AppDimensions.opacity40,
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radius8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.inset12,
                horizontal: AppDimensions.inset56,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppThemeManager.border,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusCircular,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppDimensions.inset12),
                          child: SvgPicture.asset(
                            svgIconPath ?? $AssetsIconsFilledGen().phone,
                            width: AppDimensions.icon32,
                            height: AppDimensions.icon32,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.space16),
                  Text(
                    LocaleKeys.setting_device_manager_login_more_device.trArgs([
                      titleDevice,
                    ]),
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall?.copyWith(fontFamily: 'Roboto'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
