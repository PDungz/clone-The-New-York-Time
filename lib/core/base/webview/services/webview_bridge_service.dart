import 'dart:convert';

import 'package:news_app/core/base/webview/model/webview_message.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewBridgeService {
  Function(WebViewMessage)? onMessage;

  Future<void> setupBridges(WebViewController controller) async {
    controller.addJavaScriptChannel(
      'FlutterBridge',
      onMessageReceived: (JavaScriptMessage message) {
        try {
          final webViewMessage = WebViewMessage.fromJson(message.message);
          onMessage?.call(webViewMessage);
        } catch (e) {
          // Silent fail or minimal logging
        }
      },
    );

    controller.addJavaScriptChannel(
      'FlutterDataBridge',
      onMessageReceived: (JavaScriptMessage message) {
        try {
          final webViewMessage = WebViewMessage(
            type: WebViewMessageType.pageInfo,
            data: jsonDecode(message.message),
          );
          onMessage?.call(webViewMessage);
        } catch (e) {
          // Silent fail or minimal logging
        }
      },
    );

    await _injectBridgeScript(controller);
  }

  Future<void> _injectBridgeScript(WebViewController controller) async {
    const bridgeScript = '''
      (function() {
        'use strict';
        
        // Prevent multiple injections
        if (window.flutterBridgeInjected) {
          return;
        }
        window.flutterBridgeInjected = true;
        
        window.flutterBridge = {
          sendMessage: function(type, data) {
            try {
              FlutterBridge.postMessage(JSON.stringify({
                type: type,
                data: data || {},
                timestamp: new Date().toISOString()
              }));
            } catch (e) {
              console.error('Error sending message:', e);
            }
          },
          
          sendPageData: function(data) {
            try {
              FlutterDataBridge.postMessage(JSON.stringify(data));
            } catch (e) {
              console.error('Error sending page data:', e);
            }
          },
          
          extractPageInfo: function() {
            const info = {
              title: document.title,
              url: window.location.href,
              scrollY: window.scrollY,
              scrollHeight: document.documentElement.scrollHeight,
              viewportHeight: window.innerHeight,
            };
            this.sendPageData(info);
          },
          
          handleFlutterMessage: function(message) {
            try {
              switch (message.type) {
                case 'scroll':
                  window.scrollTo(0, message.data.y || 0);
                  break;
                case 'highlight':
                  this.highlightElements(message.data.selector, message.data.color);
                  break;
                case 'apply_customizations':
                  if (window.applyWebViewCustomizations) {
                    window.applyWebViewCustomizations(true);
                  }
                  break;
                default:
                  console.log('Unknown message type:', message.type);
              }
            } catch (e) {
              console.error('Error handling message:', e);
            }
          },
          
          highlightElements: function(selector, color) {
            document.querySelectorAll(selector).forEach(el => {
              el.style.backgroundColor = color || 'yellow';
            });
          }
        };
        
        // Auto-extract page info when loaded
        if (document.readyState === 'complete') {
          setTimeout(() => window.flutterBridge.extractPageInfo(), 1000);
        } else {
          window.addEventListener('load', () => {
            setTimeout(() => window.flutterBridge.extractPageInfo(), 1000);
          });
        }
        
        // Listen for scroll events
        let scrollTimeout;
        window.addEventListener('scroll', function() {
          clearTimeout(scrollTimeout);
          scrollTimeout = setTimeout(() => {
            window.flutterBridge.sendMessage('scroll', {
              y: window.scrollY,
              height: document.documentElement.scrollHeight,
              viewport: window.innerHeight
            });
          }, 100);
        });
        
      })();
    ''';

    try {
      await controller.runJavaScript(bridgeScript);
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> sendMessageToWebView(
    WebViewController controller,
    Map<String, dynamic> message,
  ) async {
    try {
      final script = '''
        if (window.flutterBridge) {
          window.flutterBridge.handleFlutterMessage(${jsonEncode(message)});
        }
      ''';
      await controller.runJavaScript(script);
    } catch (e) {
      // Silent fail
    }
  }

  void dispose() {
    onMessage = null;
  }
}
