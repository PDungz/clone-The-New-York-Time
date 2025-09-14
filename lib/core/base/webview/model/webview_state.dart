enum WebViewStatus { initial, loading, loaded, error }

class WebViewState {
  final WebViewStatus status;
  final int progress;
  final String? currentUrl;
  final String? pageTitle;
  final String? errorMessage;
  final bool canGoBack;
  final bool canGoForward;
  final Map<String, dynamic> customData;

  const WebViewState({
    this.status = WebViewStatus.initial,
    this.progress = 0,
    this.currentUrl,
    this.pageTitle,
    this.errorMessage,
    this.canGoBack = false,
    this.canGoForward = false,
    this.customData = const {},
  });

  bool get isLoading => status == WebViewStatus.loading;
  bool get isLoaded => status == WebViewStatus.loaded;
  bool get hasError => status == WebViewStatus.error;
  bool get isInitial => status == WebViewStatus.initial;

  WebViewState copyWith({
    WebViewStatus? status,
    int? progress,
    String? currentUrl,
    String? pageTitle,
    String? errorMessage,
    bool? canGoBack,
    bool? canGoForward,
    Map<String, dynamic>? customData,
  }) {
    return WebViewState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      currentUrl: currentUrl ?? this.currentUrl,
      pageTitle: pageTitle ?? this.pageTitle,
      errorMessage: errorMessage ?? this.errorMessage,
      canGoBack: canGoBack ?? this.canGoBack,
      canGoForward: canGoForward ?? this.canGoForward,
      customData: customData ?? this.customData,
    );
  }
}
