import 'package:flutter/material.dart';
import 'package:news_app/core/theme/theme_manager.dart';
import 'package:news_app/feature/home/presentation/web/controller/home_webview_controller.dart';
import 'package:news_app/gen/assets.gen.dart';
import 'package:packages/widget/button/icon_button_widget.dart';
import 'package:packages/widget/layout/layout.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomeWebviewPage extends StatefulWidget {
  final String url;
  final String? title;

  const HomeWebviewPage({super.key, required this.url, this.title});

  @override
  State<HomeWebviewPage> createState() => _HomeWebviewPageState();
}

class _HomeWebviewPageState extends State<HomeWebviewPage> {
  late final HomeWebviewController _webViewController;
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    _webViewController = HomeWebviewController();

    // Setup callbacks
    _webViewController.onStateChanged = (state) {
      if (mounted) {
        setState(() {
          _isLoading = state.isLoading;
        });
      }
    };

    // Initialize with URL
    try {
      await _webViewController.initialize(widget.url, title: widget.title);
      print('WebView initialized successfully with URL: ${widget.url}');
    } catch (e) {
      print('Failed to initialize WebView: $e');
    }
  }

  Future<void> _refreshWebView() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      await _webViewController.refreshContent();
      print('WebView refreshed successfully');
    } catch (e) {
      print('Failed to refresh WebView: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutWidget(
      body: SafeArea(
        child: Stack(
          children: [
            _buildWebView(),
            if (_isLoading || _isRefreshing)
              Container(
                color: AppThemeManager.background.withOpacity(0.8),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppThemeManager.primary,
                      ),
                      SizedBox(height: 16),
                      Text(
                        _isRefreshing ? 'Refreshing...' : 'Loading...',
                        style: TextStyle(
                          color: AppThemeManager.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildWebView() {
    if (_webViewController.controller == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppThemeManager.primary),
            SizedBox(height: 16),
            Text(
              'Initializing WebView...',
              style: TextStyle(color: AppThemeManager.textSecondary),
            ),
          ],
        ),
      );
    }

    return WebViewWidget(controller: _webViewController.controller!);
  }

  Widget _buildBottomBar() {
    return IntrinsicHeight(
      child: Container(
        decoration: BoxDecoration(
          color: AppThemeManager.background,        
        ),
        padding: const EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: 32,
        ),
        child: Row(
          children: [
            // Back button
            IconButtonWidget(
              svgPath: $AssetsIconsFilledGen().backward,
              color: AppThemeManager.icon,
              onPressed: () => Navigator.pop(context),
            ),

            Spacer(),

            // Refresh button
            IconButtonWidget(
              svgPath: $AssetsIconsFilledGen().refresh,
              color:
                  _isRefreshing
                      ? AppThemeManager.textDisabled
                      : AppThemeManager.icon,
              onPressed: _isRefreshing ? null : _refreshWebView,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _webViewController.dispose();
    super.dispose();
  }
}
