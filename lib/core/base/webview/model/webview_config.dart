class WebViewConfig {
  final String url;
  final String? title;
  final List<String> hideSelectors;
  final Map<String, String> customStyles;
  final List<String> scriptFiles;
  final List<String> cssFiles; // NEW: Support for CSS files
  final bool hideAds;
  final bool enableJavaScript;
  final bool enableDomStorage;
  final bool enableZoom;
  final bool showProgress;
  final Duration timeout;
  final Map<String, dynamic> customData;

  const WebViewConfig({
    required this.url,
    this.title,
    this.hideSelectors = const [],
    this.customStyles = const {},
    this.scriptFiles = const [],
    this.cssFiles = const [], // NEW: CSS files list
    this.hideAds = true,
    this.enableJavaScript = true,
    this.enableDomStorage = true,
    this.enableZoom = false,
    this.showProgress = true,
    this.timeout = const Duration(seconds: 30),
    this.customData = const {},
  });

  WebViewConfig copyWith({
    String? url,
    String? title,
    List<String>? hideSelectors,
    Map<String, String>? customStyles,
    List<String>? scriptFiles,
    List<String>? cssFiles, // NEW
    bool? hideAds,
    bool? enableJavaScript,
    bool? enableDomStorage,
    bool? enableZoom,
    bool? showProgress,
    Duration? timeout,
    Map<String, dynamic>? customData,
  }) {
    return WebViewConfig(
      url: url ?? this.url,
      title: title ?? this.title,
      hideSelectors: hideSelectors ?? this.hideSelectors,
      customStyles: customStyles ?? this.customStyles,
      scriptFiles: scriptFiles ?? this.scriptFiles,
      cssFiles: cssFiles ?? this.cssFiles, // NEW
      hideAds: hideAds ?? this.hideAds,
      enableJavaScript: enableJavaScript ?? this.enableJavaScript,
      enableDomStorage: enableDomStorage ?? this.enableDomStorage,
      enableZoom: enableZoom ?? this.enableZoom,
      showProgress: showProgress ?? this.showProgress,
      timeout: timeout ?? this.timeout,
      customData: customData ?? this.customData,
    );
  }
}
