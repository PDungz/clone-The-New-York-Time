part of 'setting_cubit.dart';
class SettingState extends Equatable {
  final String themeName;
  final AppTheme theme;
  final String language;
  final bool notificationsEnabled;
  final double fontSize;
  
  // Cache related properties
  final String cacheSize;
  final bool isCacheEmpty;
  final bool isCacheLoading;
  final bool isCacheClearing;

  bool get isDarkMode => themeName == 'dark';
  bool get isEnglish => language == 'en';

  const SettingState({
    required this.themeName,
    required this.theme,
    required this.language,
    required this.notificationsEnabled,
    required this.fontSize,
    this.cacheSize = '0 B',
    this.isCacheEmpty = true,
    this.isCacheLoading = false,
    this.isCacheClearing = false,
  });

  // Factory constructor for initial state
  factory SettingState.initial() => SettingState(
    themeName: PreferenceKey.defaultTheme,
    theme: LightTheme(),
    language: PreferenceKey.defaultLanguage,
    notificationsEnabled: PreferenceKey.defaultNotifications,
    fontSize: PreferenceKey.defaultFontSize,
    cacheSize: '0 B',
    isCacheEmpty: true,
    isCacheLoading: false,
    isCacheClearing: false,
  );

  @override
  List<Object?> get props => [
    themeName,
    theme,
    language,
    notificationsEnabled,
    fontSize,
    cacheSize,
    isCacheEmpty,
    isCacheLoading,
    isCacheClearing,
  ];

  SettingState copyWith({
    String? themeName,
    AppTheme? theme,
    String? language,
    bool? notificationsEnabled,
    double? fontSize,
    String? cacheSize,
    bool? isCacheEmpty,
    bool? isCacheLoading,
    bool? isCacheClearing,
  }) {
    return SettingState(
      themeName: themeName ?? this.themeName,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      fontSize: fontSize ?? this.fontSize,
      cacheSize: cacheSize ?? this.cacheSize,
      isCacheEmpty: isCacheEmpty ?? this.isCacheEmpty,
      isCacheLoading: isCacheLoading ?? this.isCacheLoading,
      isCacheClearing: isCacheClearing ?? this.isCacheClearing,
    );
  }
}
