import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:news_app/core/base/webview/controller/base_webview_controller.dart';
import 'package:news_app/core/base/webview/model/webview_config.dart';
import 'package:news_app/core/base/webview/model/webview_message.dart';
import 'package:news_app/core/theme/theme_manager.dart';

class HomeWebviewController extends BaseWebviewController {
  // Custom callbacks for home-specific events (keeping new features)
  void Function(double progress)? onReadingProgress;
  void Function(Map<String, dynamic> pageInfo)? onPageInfoReceived;
  void Function(String error)? onCustomError;

  // Reading tracking
  double _currentReadingProgress = 0.0;
  Timer? _progressUpdateTimer;

  double get currentReadingProgress => _currentReadingProgress;

  @override
  WebViewConfig createConfig(String url, {String? title}) {
    return WebViewConfig(
      url: url,
      title: title,
      // Keep original hide selectors but add a few more
      hideSelectors: ['.NYTAppHideMasthead', '.css-7v35jk'],
      customStyles: _buildCustomStyles(), // Use original CSS structure
      hideAds: true,
      enableJavaScript: true,
      enableDomStorage: true,
      enableZoom: false,
      showProgress: true,
      timeout: const Duration(seconds: 30),
      // Add custom data from new version for enhanced features
      customData: {'theme_version': '1.0', 'reading_mode': true},
    );
  }

  /// Build custom CSS styles using theme colors and typography (KEEP ORIGINAL STRUCTURE)
  Map<String, String> _buildCustomStyles() {
    return {
      // Original body styles
      'body': '''
        background-color: ${_colorToHex(AppThemeManager.background)} !important;
        color: ${_colorToHex(AppThemeManager.textPrimary)} !important;
      ''',

      // Original heading styles
      'h1, h2, h3, h4, h5, h6': '''
        color: ${_colorToHex(AppThemeManager.textPrimary)} !important;
      ''',

      // Original paragraph styles
      'p': '''
        color: ${_colorToHex(AppThemeManager.textPrimary)} !important;
      ''',

      // Original link styles
      'a': '''
        color: ${_colorToHex(AppThemeManager.nytBlue)} !important;
      ''',

      'a:visited': '''
        color: ${_colorToHex(AppThemeManager.linkVisited)} !important;
      ''',

      'a:hover': '''
        color: ${_colorToHex(AppThemeManager.nytAccent)} !important;
        text-decoration: underline !important;
      ''',

      // Original blockquote styles
      'blockquote': '''
        background-color: ${_colorToHex(AppThemeManager.card)} !important;

      ''',

      // Original code styles
      'pre, code': '''
        background-color: ${_colorToHex(AppThemeManager.card)} !important;
        color: ${_colorToHex(AppThemeManager.textSecondary)} !important;

      ''',

      'th': '''
        background-color: ${_colorToHex(AppThemeManager.card)} !important;
      ''',

      // Original custom classes for news content
      '.breaking-news': '''
        background-color: ${_colorToHex(AppThemeManager.breakingNews)} !important;

      ''',

      '.premium-content': '''
        background: linear-gradient(135deg, ${_colorToHex(AppThemeManager.premiumGradient[0])}, ${_colorToHex(AppThemeManager.premiumGradient[1])}) !important;
      ''',
    };
  }

  @override
  Future<void> onPageLoaded(String url) async {
    if (kDebugMode) {
      print('Home WebView page loaded: $url');
    }

    // Apply original theme styles (keep original method)
    await _applyThemeStyles();

    // Add new reading progress tracking
    await _setupReadingProgressTracking();
  }

  @override
  Future<void> handleMessage(WebViewMessage message) async {
    if (isDisposed) return;

    try {
      // Keep original switch structure but add new cases
      switch (message.type) {
        case WebViewMessageType.pageInfo:
          _handlePageInfo(message.data);
          break;
        case WebViewMessageType.error:
          _handleWebViewError(message.data);
          break;
        // Add new message types for enhanced features
        case WebViewMessageType.linkClick:
          await _handleLinkClick(message.data);
          break;
        case WebViewMessageType.imageClick:
          await _handleImageClick(message.data);
          break;
        default:
          if (kDebugMode) {
            print('Unhandled message: ${message.type}');
          }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling message: $e');
      }
    }
  }

  @override
  Future<void> handleError(String error) async {
    if (kDebugMode) {
      print('WebView error occurred: $error');
    }
    onCustomError?.call(error);
  }

  /// Handle page info messages (KEEP ORIGINAL but enhance)
  void _handlePageInfo(Map<String, dynamic> data) {
    if (kDebugMode) {
      print('Page info received: ${data.keys.join(', ')}');
    }

    // Add new callback
    onPageInfoReceived?.call(data);

    // Update custom data
    updateCustomData({
      'last_page_info': data,
      'last_update': DateTime.now().toIso8601String(),
    });
  }

  /// Handle WebView error messages (KEEP ORIGINAL but enhance)
  void _handleWebViewError(Map<String, dynamic> data) {
    final error = data['error'] as String?;
    if (error != null) {
      if (kDebugMode) {
        print('WebView error: $error');
      }

      // Add error recovery logic
      final errorType = data['type'] as String? ?? 'unknown';
      if (errorType == 'network' && !isDisposed) {
        Future.delayed(Duration(seconds: 2), () {
          reapplyCustomizations();
        });
      }
    }
  }

  /// Handle link clicks for analytics (NEW)
  Future<void> _handleLinkClick(Map<String, dynamic> data) async {
    final url = data['url'] as String?;
    final text = data['text'] as String?;

    if (kDebugMode) {
      print('Link clicked: $url (text: $text)');
    }
  }

  /// Handle image clicks (NEW)
  Future<void> _handleImageClick(Map<String, dynamic> data) async {
    final src = data['src'] as String?;
    final alt = data['alt'] as String?;

    if (kDebugMode) {
      print('Image clicked: $src (alt: $alt)');
    }
  }

  /// Apply additional theme styles after page load (KEEP ORIGINAL JS but enhance)
  Future<void> _applyThemeStyles() async {
    if (controller == null) return;

    try {
      final themeScript = '''
        (function() {
          try {
            // Original theme application logic
            const root = document.documentElement;
            root.style.setProperty('--theme-background', '${_colorToHex(AppThemeManager.background)}');
            root.style.setProperty('--theme-text', '${_colorToHex(AppThemeManager.textPrimary)}');
            root.style.setProperty('--theme-primary', '${_colorToHex(AppThemeManager.primary)}');
            root.style.setProperty('--theme-secondary', '${_colorToHex(AppThemeManager.secondary)}');
            
            // Keep original element removal logic
            const unwantedElements = document.querySelectorAll('.ad, .advertisement, .banner-ad, .popup, .modal-overlay');
            unwantedElements.forEach(el => el.remove());
            
            // Add reading mode class for new features
            document.body.classList.add('reading-mode');
            
            // Add smooth scroll behavior
            document.documentElement.style.scrollBehavior = 'smooth';
            
            return 'Theme applied successfully';
          } catch (e) {
            console.error('Theme application failed:', e);
            return 'Theme application failed: ' + e.message;
          }
        })();
      ''';

      final result = await controller!.runJavaScriptReturningResult(
        themeScript,
      );
      if (kDebugMode) {
        print('Theme application result: $result');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to apply theme styles: $e');
      }
    }
  }

  /// Setup reading progress tracking (NEW feature)
  Future<void> _setupReadingProgressTracking() async {
    if (isDisposed || controller == null) return;

    try {
      final progressScript = '''
        (function() {
          // Enhanced scroll tracking with original simplicity
          let lastProgress = 0;
          window.addEventListener('scroll', function() {
            const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
            const scrollHeight = document.documentElement.scrollHeight - window.innerHeight;
            const progress = scrollHeight > 0 ? (scrollTop / scrollHeight) * 100 : 0;
            
            // Send progress updates (throttled)
            if (Math.abs(progress - lastProgress) > 1) {
              if (window.flutterBridge) {
                window.flutterBridge.sendMessage('scroll', {
                  y: scrollTop,
                  height: document.documentElement.scrollHeight,
                  viewport: window.innerHeight,
                  progress: progress
                });
              }
              lastProgress = progress;
            }
          }, { passive: true });
          
          return 'Reading progress tracking setup complete';
        })();
      ''';

      await controller!.runJavaScript(progressScript);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to setup reading progress: $e');
      }
    }
  }

  /// Refresh content with theme reapplication (ENHANCED)
  Future<void> refreshContent() async {
    if (isDisposed) return;

    _currentReadingProgress = 0.0;
    await reload();
  }

  /// Convert Color to hex string (KEEP ORIGINAL)
  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  @override
  void dispose() {
    _progressUpdateTimer?.cancel();
    onReadingProgress = null;
    onPageInfoReceived = null;
    onCustomError = null;
    super.dispose();
  }
}
