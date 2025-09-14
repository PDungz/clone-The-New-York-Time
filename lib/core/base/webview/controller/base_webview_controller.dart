// Enhanced version với performance improvements và error handling tốt hơn

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:news_app/core/base/webview/model/webview_config.dart';
import 'package:news_app/core/base/webview/model/webview_message.dart';
import 'package:news_app/core/base/webview/model/webview_state.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../services/webview_bridge_service.dart';
import '../services/webview_script_service.dart';

abstract class BaseWebviewController {
  WebViewController? _controller;
  WebViewConfig? _config;
  WebViewState _state = const WebViewState();
  late final WebViewScriptService _scriptService;
  late final WebViewBridgeService _bridgeService;

  // Performance tracking
  final Map<String, DateTime> _performanceMetrics = {};
  bool _isDisposed = false;

  // Debounce helpers
  Timer? _customizationDebounceTimer;
  Timer? _stateUpdateDebounceTimer;

  // Callbacks với null safety tốt hơn
  void Function(WebViewState state)? onStateChanged;
  void Function(WebViewMessage message)? onMessageReceived;
  void Function(String error)? onError;
  void Function(Map<String, dynamic> metrics)? onPerformanceUpdate;

  // Getters
  WebViewController? get controller => _controller;
  WebViewConfig? get config => _config;
  WebViewState get state => _state;
  bool get isDisposed => _isDisposed;
  Map<String, dynamic> get performanceMetrics => Map.from(_performanceMetrics);

  BaseWebviewController() {
    _scriptService = WebViewScriptService();
    _bridgeService = WebViewBridgeService();
    _bridgeService.onMessage = _handleWebViewMessage;
    _startPerformanceTracking();
  }

  // Abstract methods
  WebViewConfig createConfig(String url, {String? title});
  Future<void> onPageLoaded(String url);
  Future<void> handleMessage(WebViewMessage message);
  Future<void> handleError(String error);

  void _startPerformanceTracking() {
    _performanceMetrics['controller_created'] = DateTime.now();
  }

  Future<void> initialize(String url, {String? title}) async {
    if (_isDisposed) return;

    try {
      _performanceMetrics['initialize_start'] = DateTime.now();

      _config = createConfig(url, title: title);
      _updateStateDebounced(_state.copyWith(status: WebViewStatus.loading));

      _controller =
          WebViewController()
            ..setJavaScriptMode(
              _config!.enableJavaScript
                  ? JavaScriptMode.unrestricted
                  : JavaScriptMode.disabled,
            )
            ..setNavigationDelegate(
              NavigationDelegate(
                onPageStarted: _onPageStarted,
                onProgress: _onProgress,
                onPageFinished: _onPageFinished,
                onWebResourceError: _onWebResourceError,
                onNavigationRequest: (NavigationRequest request) {
                  // Pre-inject critical styles với error handling
                  _preInjectCriticalStylesSafe();
                  return NavigationDecision.navigate;
                },
              ),
            );

      await _bridgeService.setupBridges(_controller!);
      await _preInjectCriticalStylesSafe();
      await _controller!.loadRequest(Uri.parse(url));

      _performanceMetrics['initialize_end'] = DateTime.now();
    } catch (e) {
      await _handleError('Failed to initialize WebView: $e');
    }
  }

  // Safe version of pre-inject với better error handling
  Future<void> _preInjectCriticalStylesSafe() async {
    if (_isDisposed || _controller == null || _config == null) return;

    try {
      final criticalCSS = _generateCriticalCSS(_config!);
      if (criticalCSS.isEmpty) return;

      final script = '''
        (function() {
          try {
            const existingStyle = document.getElementById('webview-critical-styles');
            if (existingStyle) {
              existingStyle.remove();
            }
            
            const style = document.createElement('style');
            style.id = 'webview-critical-styles';
            style.type = 'text/css';
            style.innerHTML = `$criticalCSS`;
            
            const head = document.head || document.getElementsByTagName('head')[0];
            if (head) {
              head.insertBefore(style, head.firstChild);
            } else {
              const newHead = document.createElement('head');
              newHead.appendChild(style);
              document.documentElement.insertBefore(newHead, document.documentElement.firstChild);
            }
          } catch (e) {
            console.warn('Critical styles injection failed:', e);
          }
        })();
      ''';

      await _controller!.runJavaScript(script);
    } catch (e) {
      if (kDebugMode) {
        print('Pre-inject critical styles failed: $e');
      }
    }
  }

  String _generateCriticalCSS(WebViewConfig config) {
    final cssRules = <String>[];

    // Enhanced hiding với animation prevention
    if (config.hideSelectors.isNotEmpty) {
      for (final selector in config.hideSelectors) {
        cssRules.add('''
          $selector { 
            display: none !important; 
            visibility: hidden !important; 
            opacity: 0 !important;
            height: 0 !important;
            width: 0 !important;
            overflow: hidden !important;
            position: absolute !important;
            left: -9999px !important;
            animation: none !important;
            transition: none !important;
          }
        ''');
      }
    }

    // Enhanced ad blocking với more selectors
    if (config.hideAds) {
      cssRules.addAll([
        '''
        .advertisement, .ads, .google-ads, .sponsored, .ad-banner, .adsense, 
        .adsbygoogle, .ad-wrapper, .ad-content, .ad-slot, .advertising,
        .sponsor, .promoted, .promotion, .popup-ad, .banner-ad {
          display: none !important;
          visibility: hidden !important;
          opacity: 0 !important;
          height: 0 !important;
          width: 0 !important;
          overflow: hidden !important;
          position: absolute !important;
          left: -9999px !important;
        }
        ''',
        '''
        [class*="ad-"], [id*="ad-"], [class*="ads-"], [id*="ads-"],
        [class*="sponsor"], [id*="sponsor"], [class*="popup"], [id*="popup"] {
          display: none !important;
          visibility: hidden !important;
        }
        ''',
        '''
        iframe[src*="ads"], iframe[src*="doubleclick"], 
        iframe[src*="googlesyndication"], iframe[src*="googleadservices"] {
          display: none !important;
          visibility: hidden !important;
        }
        ''',
      ]);
    }

    // Custom styles với higher specificity
    if (config.customStyles.isNotEmpty) {
      cssRules.addAll(
        config.customStyles.entries.map((e) => '${e.key} { ${e.value} }'),
      );
    }

    return cssRules.join('\n');
  }

  void _onPageStarted(String url) {
    _performanceMetrics['page_start'] = DateTime.now();

    _updateStateDebounced(
      _state.copyWith(
        status: WebViewStatus.loading,
        progress: 0,
        currentUrl: url,
        errorMessage: null,
      ),
    );

    _preInjectCriticalStylesSafe();
  }

  void _onProgress(int progress) {
    _updateStateDebounced(_state.copyWith(progress: progress));

    // Apply customizations at key milestones với debouncing
    if (progress == 25 || progress == 50 || progress == 75) {
      _quickApplyCustomizationsDebounced();
    }
  }

  // Debounced version để tránh spam customization calls
  void _quickApplyCustomizationsDebounced() {
    _customizationDebounceTimer?.cancel();
    _customizationDebounceTimer = Timer(Duration(milliseconds: 50), () {
      _quickApplyCustomizations();
    });
  }

  Future<void> _quickApplyCustomizations() async {
    if (_isDisposed || _controller == null || _config == null) return;

    try {
      final quickScript = '''
        (function() {
          if (window.applyWebViewCustomizations) {
            window.applyWebViewCustomizations();
          }
        })();
      ''';
      await _controller!.runJavaScript(quickScript);
    } catch (e) {
      // Silent fail với optional logging
      if (kDebugMode) {
        print('Quick customizations failed: $e');
      }
    }
  }

  Future<void> _onPageFinished(String url) async {
    if (_isDisposed) return;

    try {
      _performanceMetrics['page_finished'] = DateTime.now();

      if (_config != null && _controller != null) {
        await _applyCustomizationsAggressively();
      }

      final title = await _controller?.runJavaScriptReturningResult(
        'document.title',
      );
      final pageTitle = title?.toString().replaceAll('"', '') ?? _config?.title;

      final canGoBack = await _controller?.canGoBack() ?? false;
      final canGoForward = await _controller?.canGoForward() ?? false;

      _updateStateDebounced(
        _state.copyWith(
          status: WebViewStatus.loaded,
          progress: 100,
          pageTitle: pageTitle,
          canGoBack: canGoBack,
          canGoForward: canGoForward,
        ),
      );

      await onPageLoaded(url);
      _reportPerformanceMetrics();
    } catch (e) {
      await _handleError('Error on page finished: $e');
    }
  }

  void _reportPerformanceMetrics() {
    if (_performanceMetrics.containsKey('initialize_start') &&
        _performanceMetrics.containsKey('page_finished')) {
      final loadTime =
          _performanceMetrics['page_finished']!
              .difference(_performanceMetrics['initialize_start']!)
              .inMilliseconds;

      final metrics = {
        'total_load_time_ms': loadTime,
        'page_start_to_finish_ms':
            _performanceMetrics.containsKey('page_start')
                ? _performanceMetrics['page_finished']!
                    .difference(_performanceMetrics['page_start']!)
                    .inMilliseconds
                : null,
        'timestamp': DateTime.now().toIso8601String(),
      };

      onPerformanceUpdate?.call(metrics);
    }
  }

  Future<void> _applyCustomizationsAggressively() async {
    if (_isDisposed || _controller == null || _config == null) return;

    try {
      // Apply với timeout để tránh hang
      await Future.any([
        _scriptService.injectCustomizations(_controller!, _config!),
        Future.delayed(
          Duration(seconds: 5),
          () => throw TimeoutException('Customization timeout'),
        ),
      ]);

      // Setup monitoring với error handling
      await _setupContinuousMonitoringSafe();
    } catch (e) {
      if (kDebugMode) {
        print('Aggressive customizations failed: $e');
      }
      // Fallback to basic
      await _applyBasicCustomizationsSafe();
    }
  }

  Future<void> _setupContinuousMonitoringSafe() async {
    if (_isDisposed || _controller == null || _config == null) return;

    final monitoringScript = '''
      (function() {
        if (window.webViewMonitoringSetup) return;
        window.webViewMonitoringSetup = true;
        
        try {
          let isMonitoring = false;
          let lastApply = 0;
          const THROTTLE_MS = 100;
          
          function throttledApply() {
            const now = Date.now();
            if (now - lastApply < THROTTLE_MS) return;
            lastApply = now;
            
            if (window.applyWebViewCustomizations) {
              window.applyWebViewCustomizations();
            }
          }
          
          function startMonitoring() {
            if (isMonitoring) return;
            isMonitoring = true;
            
            // Apply immediately
            throttledApply();
            
            // Setup optimized MutationObserver
            if (window.MutationObserver) {
              const observer = new MutationObserver(function(mutations) {
                let needsUpdate = false;
                
                for (let mutation of mutations) {
                  if (mutation.type === 'childList' && mutation.addedNodes.length > 0) {
                    for (let node of mutation.addedNodes) {
                      if (node.nodeType === 1) {
                        needsUpdate = true;
                        break;
                      }
                    }
                  }
                  if (needsUpdate) break;
                }
                
                if (needsUpdate) {
                  setTimeout(throttledApply, 10);
                }
              });
              
              if (document.body) {
                observer.observe(document.body, { 
                  childList: true, 
                  subtree: true 
                });
              }
            }
            
            // Periodic reapply for first 10 seconds
            let count = 0;
            const interval = setInterval(() => {
              throttledApply();
              count++;
              if (count >= 5) clearInterval(interval);
            }, 2000);
          }
          
          if (document.readyState === 'complete') {
            startMonitoring();
          } else {
            window.addEventListener('load', startMonitoring);
          }
          
        } catch (e) {
          console.warn('Monitoring setup failed:', e);
        }
      })();
    ''';

    try {
      await _controller!.runJavaScript(monitoringScript);
    } catch (e) {
      if (kDebugMode) {
        print('Monitoring setup failed: $e');
      }
    }
  }

  Future<void> _applyBasicCustomizationsSafe() async {
    if (_isDisposed || _controller == null || _config == null) return;

    try {
      final basicScript = '''
        (function() {
          try {
            // Basic hide selectors
            ${_config!.hideSelectors.map((selector) => '''
              document.querySelectorAll('$selector').forEach(el => {
                el.style.setProperty('display', 'none', 'important');
                el.style.setProperty('visibility', 'hidden', 'important');
              });
            ''').join('\n')}
            
            // Basic ad blocking
            if (${_config!.hideAds}) {
              const adSelectors = ['.advertisement', '.ads', '.google-ads', '.sponsored'];
              adSelectors.forEach(selector => {
                document.querySelectorAll(selector).forEach(el => {
                  el.style.display = 'none';
                  el.remove();
                });
              });
            }
            
            // Basic custom styles
            if (${_config!.customStyles.isNotEmpty}) {
              const style = document.createElement('style');
              style.innerHTML = `${_config!.customStyles.entries.map((e) => '${e.key} { ${e.value} }').join('\n')}`;
              if (document.head) {
                document.head.appendChild(style);
              }
            }
            
          } catch (e) {
            console.warn('Basic customizations failed:', e);
          }
        })();
      ''';

      await _controller!.runJavaScript(basicScript);
    } catch (e) {
      if (kDebugMode) {
        print('Basic customizations failed: $e');
      }
    }
  }

  void _onWebResourceError(WebResourceError error) {
    _handleError('${error.description} (${error.errorCode})');
  }

  Future<void> _handleError(String error) async {
    if (_isDisposed) return;

    _updateStateDebounced(
      _state.copyWith(
        status: WebViewStatus.error,
        errorMessage: error,
        progress: 100,
      ),
    );

    onError?.call(error);
    await handleError(error);
  }

  Future<void> _handleWebViewMessage(WebViewMessage message) async {
    if (_isDisposed) return;

    onMessageReceived?.call(message);
    await handleMessage(message);
  }

  // Debounced state update để tránh spam callbacks
  void _updateStateDebounced(WebViewState newState) {
    _stateUpdateDebounceTimer?.cancel();
    _stateUpdateDebounceTimer = Timer(Duration(milliseconds: 16), () {
      _updateState(newState);
    });
  }

  void _updateState(WebViewState newState) {
    if (_isDisposed) return;

    _state = newState;
    onStateChanged?.call(_state);
  }

  // Public methods với null checks
  Future<void> reload() async {
    if (_isDisposed || _controller == null) return;
    await _controller!.reload();
  }

  Future<void> goBack() async {
    if (_isDisposed || _controller == null || !_state.canGoBack) return;
    await _controller!.goBack();
  }

  Future<void> goForward() async {
    if (_isDisposed || _controller == null || !_state.canGoForward) return;
    await _controller!.goForward();
  }

  Future<void> sendMessageToWebView(Map<String, dynamic> message) async {
    if (_isDisposed || _controller == null) return;
    await _bridgeService.sendMessageToWebView(_controller!, message);
  }

  Future<String?> evaluateJavaScript(String script) async {
    if (_isDisposed || _controller == null) return null;

    try {
      final result = await _controller!.runJavaScriptReturningResult(script);
      return result.toString();
    } catch (e) {
      if (kDebugMode) {
        print('JavaScript evaluation failed: $e');
      }
      return null;
    }
  }

  Future<void> reapplyCustomizations() async {
    if (_isDisposed || _controller == null || _config == null) return;
    await _applyCustomizationsAggressively();
  }

  void updateCustomData(Map<String, dynamic> data) {
    if (_isDisposed) return;

    final newCustomData = Map<String, dynamic>.from(_state.customData)
      ..addAll(data);
    _updateStateDebounced(_state.copyWith(customData: newCustomData));
  }

  void dispose() {
    _isDisposed = true;
    _customizationDebounceTimer?.cancel();
    _stateUpdateDebounceTimer?.cancel();
    _controller = null;
    _bridgeService.dispose();
    onStateChanged = null;
    onMessageReceived = null;
    onError = null;
    onPerformanceUpdate = null;
    _performanceMetrics.clear();
  }
}
