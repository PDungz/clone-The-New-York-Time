import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:news_app/core/service/device/device_display/display_service.dart';
import 'package:news_app/core/service/device/device_info/device_info_service.dart';
import 'package:news_app/core/theme/theme_manager.dart';
import 'package:news_app/gen/assets.gen.dart';
import 'package:packages/widget/app_bar/app_bar_widget.dart';
import 'package:packages/widget/button/icon_button_widget.dart';
import 'package:packages/widget/layout/layout.dart';

class SettingTestPage extends StatefulWidget {
  const SettingTestPage({super.key});

  @override
  State<SettingTestPage> createState() => _SettingTestPageState();
}

class _SettingTestPageState extends State<SettingTestPage> {
  // Display info
  Map<String, dynamic>? displayInfo;
  bool isLoadingDisplay = true;
  bool _hasLoadedOnce = false;

  // Device info variables
  Map<String, dynamic>? deviceInfo;
  bool isLoadingDevice = true;

  final DisplayService _displayService = DisplayService.instance;
  final DeviceInfoService _deviceInfoService = DeviceInfoService.instance;

  @override
  void initState() {
    super.initState();
  }

  // ✅ THÊM: Safe helper method để get location info
  Map<String, dynamic>? _getLocationInfo(dynamic locationData) {
    if (locationData == null) return null;

    if (locationData is Map<String, dynamic>) {
      return locationData;
    } else if (locationData is Map) {
      // Convert Map<Object?, Object?> to Map<String, dynamic>
      return locationData.map((key, value) => MapEntry(key.toString(), value));
    }

    return null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedOnce) {
      _hasLoadedOnce = true;
      _loadDisplayInfo();
      _loadDeviceInfo();
    }
  }

  Future<void> _loadDisplayInfo() async {
    try {
      final info = await _displayService.getDisplayInfo();
      setState(() {
        displayInfo = info;
        isLoadingDisplay = false;
      });
    } catch (e) {
      setState(() {
        isLoadingDisplay = false;
      });
      print('Error loading display info: $e');
    }
  }

  Future<void> _loadDeviceInfo() async {
    try {
      // ✅ Sử dụng async method để có location data đầy đủ
      final info = await _deviceInfoService.getDeviceInfo();
      setState(() {
        deviceInfo = info;
        isLoadingDevice = false;
      });
    } catch (e) {
      setState(() {
        isLoadingDevice = false;
      });
      print('Error loading device info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutWidget(
      appBar: AppBarWidget(
        backgroundColor: AppThemeManager.appBar.withValues(alpha: 0.8),
        boxShadow: BoxShadow(color: AppThemeManager.shadow, blurRadius: 4, offset: const Offset(0, 1)),
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
          "Setting Device Test",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontFamily: 'Roboto'),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
            // Device Info Section
            if (isLoadingDevice)
              const Center(child: CircularProgressIndicator())
            else if (deviceInfo == null)
              const Center(child: Text('Failed to load device info'))
            else
              _buildDeviceInfo(),

            const SizedBox(height: 20),

            // Display Info Section
            if (isLoadingDisplay)
              const Center(child: CircularProgressIndicator())
            else if (displayInfo == null)
              const Center(child: Text('Failed to load display info'))
            else
              _buildDisplayInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceInfo() {
    final info = deviceInfo!;
    // ✅ FIX: Safe type casting for location info
    final locationInfo = _getLocationInfo(info['location']);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSection('📱 Device Information', [
            _buildInfoTile('Device Name', info['deviceName'] ?? 'Unknown'),
            _buildInfoTile('Device Type', info['deviceType'] ?? 'Unknown'),
            _buildInfoTile('Platform', info['platform'] ?? 'Unknown'),
            _buildInfoTile('Platform Version', info['platformVersion'] ?? 'Unknown'),
            _buildInfoTile('App Version', info['appVersion'] ?? 'Unknown'),
          ]),

          _buildSection('🆔 Device Identity', [
            _buildInfoTile('Device Identifier', info['deviceIdentifier'] ?? 'Unknown'),
            _buildInfoTile('Is Primary', (info['isPrimary'] ?? false).toString()),
            _buildInfoTile('Status', info['status'] ?? 'Unknown'),
            _buildInfoTile('Is Active', (info['isActive'] ?? false).toString()),
          ]),

          _buildSection('🌍 System Settings', [
            _buildInfoTile('Screen Resolution', info['screenResolution'] ?? 'Unknown'),
            _buildInfoTile('Timezone', info['timezone'] ?? 'Unknown'),
            _buildInfoTile('Language', info['language'] ?? 'Unknown'),
          ]),

          // ✅ THÊM: Location Information Section
          if (locationInfo != null) ...[
            _buildSection('📍 Location Information', [
              _buildInfoTile('IP Address', locationInfo['ipAddress'] ?? 'Unknown'),
              _buildInfoTile('Country', locationInfo['country'] ?? 'Unknown'),
              _buildInfoTile('City', locationInfo['city'] ?? 'Unknown'),
              _buildInfoTile(
                'Coordinates',
                '${(locationInfo['latitude'] ?? 0.0).toStringAsFixed(4)}, ${(locationInfo['longitude'] ?? 0.0).toStringAsFixed(4)}',
              ),
            ]),
          ],

          _buildSection('🔔 Push Notification', [
            _buildInfoTile('Push Enabled', (info['isPushEnabled'] ?? false).toString()),
            _buildInfoTile('Push Token', info['pushToken'] ?? 'No token'),
          ]),

          // ✅ CẬP NHẬT: API Preview Section với location
          _buildSection('📊 API Data Preview', [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ready for API:',
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getApiPreviewText(info),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ]),

          // Device Test Actions
          _buildSection('🧪 Device Test Actions', [
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _testDeviceFunctions,
                        icon: const Icon(Icons.phone_android),
                        label: const Text('Test Device'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _testLocationFunctions,
                        icon: const Icon(Icons.location_on),
                        label: const Text('Test Location'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _copyDeviceInfoToClipboard,
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy JSON'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _refreshAllData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh All'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildDisplayInfo() {
    final info = displayInfo!;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSection('🎨 Theme & Display', [
            _buildInfoTile('Theme Mode', info['themeMode'] ?? 'Unknown'),
            _buildInfoTile('Is Dark Mode', (info['isDarkMode'] ?? false).toString()),
            _buildInfoTile(
              'Screen Brightness',
              '${((info['screenBrightness'] ?? 0.0) * 100).toInt()}%',
            ),
          ]),

          _buildSection('🔤 Font Settings', [
            _buildInfoTile('Font Size', '${(info['fontSize'] ?? 16.0).toStringAsFixed(1)}px'),
            _buildInfoTile(
              'Text Scale Factor',
              (info['textScaleFactor'] ?? 1.0).toStringAsFixed(2),
            ),
            _buildInfoTile('Font Family', info['fontFamily'] ?? 'Unknown'),
            _buildInfoTile('Bold Text', (info['isBoldTextEnabled'] ?? false).toString()),
            _buildInfoTile('Large Text', (info['isLargeTextEnabled'] ?? false).toString()),
          ]),

          _buildSection('📱 Screen Information', [
            _buildInfoTile(
              'Resolution',
              '${(info['screenWidth'] ?? 0).toInt()} x ${(info['screenHeight'] ?? 0).toInt()}',
            ),
            _buildInfoTile('Orientation', info['orientation'] ?? 'Unknown'),
            _buildInfoTile(
              'Device Pixel Ratio',
              (info['devicePixelRatio'] ?? 1.0).toStringAsFixed(1),
            ),
            _buildInfoTile('Screen Density', '${(info['screenDensity'] ?? 160).toInt()} dpi'),
            _buildInfoTile(
              'Screen Size',
              '${(info['screenInches'] ?? 0.0).toStringAsFixed(1)} inches',
            ),
            _buildInfoTile(
              'Screen Category',
              _getScreenSizeCategory((info['screenInches'] ?? 0.0).toDouble()),
            ),
          ]),

          _buildSection('🎨 Color & Accessibility', [
            _buildInfoTile('Color Scheme', info['colorScheme'] ?? 'Unknown'),
            _buildInfoTile('High Contrast', (info['isHighContrastEnabled'] ?? false).toString()),
            _buildInfoTile('Invert Colors', (info['isInvertColorsEnabled'] ?? false).toString()),
          ]),

          _buildSection('🎬 Animation Settings', [
            _buildInfoTile('Reduce Motion', (info['isReduceMotionEnabled'] ?? false).toString()),
            _buildInfoTile(
              'Animation Scale',
              (info['animationDurationScale'] ?? 1.0).toStringAsFixed(2),
            ),
            _buildInfoTile(
              'Transition Scale',
              (info['transitionAnimationScale'] ?? 1.0).toStringAsFixed(2),
            ),
          ]),

          _buildSection('🌍 System Information', [
            _buildInfoTile('Language', info['languageCode'] ?? 'Unknown'),
            _buildInfoTile('RTL Layout', (info['isRTL'] ?? false).toString()),
            _buildInfoTile(
              'Status Bar Height',
              '${(info['statusBarHeight'] ?? 0.0).toStringAsFixed(1)}px',
            ),
            _buildInfoTile(
              'Navigation Bar Height',
              '${(info['navigationBarHeight'] ?? 0.0).toStringAsFixed(1)}px',
            ),
          ]),

          const SizedBox(height: 20),

          _buildSection('🧪 Display Functions Test', [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _testNativeFunctions,
                    child: const Text('Test Display'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loadDisplayInfo,
                    child: const Text('Refresh Display'),
                  ),
                ),
              ],
            ),
          ]),

          const SizedBox(height: 12),

          ElevatedButton(
            onPressed: () {
              print('📱 Display info: $displayInfo');
              print('🔧 Device info: $deviceInfo');
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('All info logged to console')));
            },
            child: const Text('Log All Info to Console'),
          ),
        ],
      ),
    );
  }

  // Test device functions
  Future<void> _testDeviceFunctions() async {
    try {
      print('🧪 Testing device functions...');

      final deviceName = await _deviceInfoService.getDeviceName();
      final deviceType = await _deviceInfoService.getDeviceType();
      final platform = await _deviceInfoService.getPlatform();
      final platformVersion = await _deviceInfoService.getPlatformVersion();
      final deviceId = await _deviceInfoService.getDeviceIdentifier();
      final screenRes = await _deviceInfoService.getScreenResolution();
      final timezone = await _deviceInfoService.getTimezone();
      final language = await _deviceInfoService.getLanguage();

      print('📱 Device Name: $deviceName');
      print('📱 Device Type: $deviceType');
      print('💻 Platform: $platform');
      print('📋 Platform Version: $platformVersion');
      print('🆔 Device ID: $deviceId');
      print('🖥️ Screen Resolution: $screenRes');
      print('🌍 Timezone: $timezone');
      print('🌎 Language: $language');

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Device functions tested! Check console')));
      }
    } catch (e) {
      print('❌ Error testing device functions: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  // ✅ THÊM: Test location functions
  Future<void> _testLocationFunctions() async {
    try {
      print('🧪 Testing location functions...');

      final locationInfo = await _deviceInfoService.getLocationInfo();
      final ipAddress = await _deviceInfoService.getIpAddress();
      final country = await _deviceInfoService.getCountry();
      final city = await _deviceInfoService.getCity();
      final coordinates = await _deviceInfoService.getCoordinates();

      print('📍 Full Location Info: $locationInfo');
      print('🌐 IP Address: $ipAddress');
      print('🏳️ Country: $country');
      print('🏙️ City: $city');
      print('📌 Coordinates: $coordinates');

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Location functions tested! Check console')));
      }
    } catch (e) {
      print('❌ Error testing location functions: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location Error: $e')));
      }
    }
  }

  Future<void> _copyDeviceInfoToClipboard() async {
    if (deviceInfo != null) {
      final apiData = await _deviceInfoService.getApiDeviceInfo();
      if (apiData != null) {
        String jsonString = _formatJsonString(apiData);
        await Clipboard.setData(ClipboardData(text: jsonString));

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Device info copied to clipboard!')),
          );
        }
      }
    }
  }

  Future<void> _refreshAllData() async {
    setState(() {
      isLoadingDisplay = true;
      isLoadingDevice = true;
    });

    await Future.wait([_loadDisplayInfo(), _loadDeviceInfo()]);
  }

  Future<void> _testNativeFunctions() async {
    try {
      print('🧪 Testing individual native functions...');

      final isPortrait = await _displayService.isPortrait();
      final isLandscape = await _displayService.isLandscape();
      final isDarkMode = await _displayService.isDarkMode();
      final screenSize = await _displayService.getScreenSize();
      final refreshRate = await _displayService.getRefreshRate();
      final screenInches = await _displayService.getScreenInches();

      print('📱 Is Portrait: $isPortrait');
      print('📱 Is Landscape: $isLandscape');
      print('🌙 Is Dark Mode: $isDarkMode');
      print('📏 Screen Size: $screenSize');
      print('🔄 Refresh Rate: $refreshRate Hz');
      print('📐 Screen Inches: $screenInches"');

      final orientation = await _displayService.orientation;
      final brightness = await _displayService.screenBrightness;
      final fontSize = await _displayService.fontSize;
      final themeMode = await _displayService.themeMode;

      print('🔄 Convenience - Orientation: $orientation');
      print('💡 Convenience - Brightness: ${(brightness * 100).toInt()}%');
      print('📝 Convenience - Font Size: $fontSize');
      print('🎨 Convenience - Theme: $themeMode');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Native functions tested! Check console for results'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ Error testing native functions: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(child: SelectableText(value, style: const TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }

  String _getScreenSizeCategory(double inches) {
    if (inches < 4.0) return 'small';
    if (inches < 5.5) return 'normal';
    if (inches < 7.0) return 'large';
    return 'xlarge';
  }

  // ✅ CẬP NHẬT: API preview text với location
  String _getApiPreviewText(Map<String, dynamic> info) {
    final locationInfo = _getLocationInfo(info['location']);

    return '''{
  "deviceName": "${info['deviceName']}",
  "deviceType": "${info['deviceType']}",
  "platform": "${info['platform']}",
  "platformVersion": "${info['platformVersion']}",
  "appVersion": "${info['appVersion']}",
  "deviceIdentifier": "${info['deviceIdentifier']}",
  "pushToken": null,
  "screenResolution": "${info['screenResolution']}",
  "timezone": "${info['timezone']}",
  "language": "${info['language']}",
  "isPushEnabled": false,
  "isActive": ${info['isActive']},
  "isPrimary": ${info['isPrimary']},
  "status": "${info['status']}",
  "location": {
    "ipAddress": "${locationInfo?['ipAddress'] ?? 'Unknown'}",
    "country": "${locationInfo?['country'] ?? 'Unknown'}",
    "city": "${locationInfo?['city'] ?? 'Unknown'}",
    "latitude": ${locationInfo?['latitude'] ?? 0.0},
    "longitude": ${locationInfo?['longitude'] ?? 0.0}
  }
}''';
  }

  String _formatJsonString(Map<String, dynamic> data) {
    String jsonString = '{\n';
    data.forEach((key, value) {
      if (value is Map) {
        jsonString += '  "$key": {\n';
        (value).forEach((subKey, subValue) {
          if (subValue is String) {
            jsonString += '    "$subKey": "$subValue",\n';
          } else {
            jsonString += '    "$subKey": $subValue,\n';
          }
        });
        jsonString += '  },\n';
      } else if (value is String) {
        jsonString += '  "$key": "$value",\n';
      } else if (value == null) {
        jsonString += '  "$key": null,\n';
      } else {
        jsonString += '  "$key": $value,\n';
      }
    });
    jsonString = jsonString.substring(0, jsonString.length - 2); // Remove last comma
    jsonString += '\n}';
    return jsonString;
  }
}
