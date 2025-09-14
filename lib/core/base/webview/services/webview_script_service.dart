import 'package:flutter/services.dart';
import 'package:news_app/core/base/webview/model/webview_config.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScriptService {
  static final WebViewScriptService _instance =
      WebViewScriptService._internal();
  factory WebViewScriptService() => _instance;
  WebViewScriptService._internal();

  final Map<String, String> _scriptCache = {};

  Future<String> loadScript(String fileName) async {
    if (_scriptCache.containsKey(fileName)) {
      return _scriptCache[fileName]!;
    }

    try {
      final script = await rootBundle.loadString(fileName);
      _scriptCache[fileName] = script;
      return script;
    } catch (e) {
      return '';
    }
  }

  Future<void> injectCustomizations(
    WebViewController controller,
    WebViewConfig config,
  ) async {
    try {
      // 1. Load và inject script files trước
      for (final scriptFile in config.scriptFiles) {
        final script = await loadScript(scriptFile);
        if (script.isNotEmpty) {
          await controller.runJavaScript(script);
        }
      }

      // 2. Inject main customization script với aggressive timing
      final script = _generateAggressiveCustomizationScript(config);
      if (script.isNotEmpty) {
        await controller.runJavaScript(script);
      }

      // 3. Apply immediate customizations để đảm bảo không bị delay
      await _applyImmediateCustomizations(controller, config);
    } catch (e) {
      // Fallback to basic script nếu main script fail
      await _injectFallbackScript(controller, config);
    }
  }

  // Apply customizations ngay lập tức không chờ DOM ready
  Future<void> _applyImmediateCustomizations(
    WebViewController controller,
    WebViewConfig config,
  ) async {
    try {
      final immediateScript = '''
        (function() {
          'use strict';
          
          function applyImmediateCustomizations() {
            try {
              // Hide selectors ngay lập tức với force
              ${config.hideSelectors.map((selector) => '''
                document.querySelectorAll('$selector').forEach(el => {
                  el.style.setProperty('display', 'none', 'important');
                  el.style.setProperty('visibility', 'hidden', 'important');
                  el.style.setProperty('opacity', '0', 'important');
                });
              ''').join('\n')}
              
              // Ad blocking ngay lập tức
              ${config.hideAds ? '''
                const adSelectors = ['.advertisement', '.ads', '.google-ads', '.sponsored'];
                adSelectors.forEach(selector => {
                  document.querySelectorAll(selector).forEach(el => {
                    el.style.setProperty('display', 'none', 'important');
                    el.remove();
                  });
                });
              ''' : ''}
              
              // Apply custom styles ngay lập tức
              ${config.customStyles.isNotEmpty ? '''
                let immediateStyle = document.getElementById('immediate-webview-styles');
                if (!immediateStyle) {
                  immediateStyle = document.createElement('style');
                  immediateStyle.id = 'immediate-webview-styles';
                  immediateStyle.innerHTML = `${config.customStyles.entries.map((e) => '${e.key} { ${e.value} }').join('\n')}`;
                  
                  const head = document.head || document.getElementsByTagName('head')[0];
                  if (head) {
                    head.insertBefore(immediateStyle, head.firstChild);
                  }
                }
              ''' : ''}
              
            } catch (e) {
              console.error('Immediate customizations error:', e);
            }
          }
          
          // Apply ngay lập tức
          applyImmediateCustomizations();
          
          // Apply lại sau micro task
          setTimeout(applyImmediateCustomizations, 0);
          
          // Apply lại với delays khác nhau
          [10, 50, 100].forEach(delay => {
            setTimeout(applyImmediateCustomizations, delay);
          });
          
        })();
      ''';

      await controller.runJavaScript(immediateScript);
    } catch (e) {
      // Silent fail for immediate customizations
    }
  }

  String _generateAggressiveCustomizationScript(WebViewConfig config) {
    return '''
      (function() {
        'use strict';
        
        // Prevent multiple injection
        if (window.webViewCustomizationInjected) {
          return;
        }
        window.webViewCustomizationInjected = true;
        
        // Customization state tracking
        let customizationState = {
          applied: false,
          retryCount: 0,
          maxRetries: 10,
          lastApplied: 0,
          isRunning: false
        };
        
        // Global function để apply customizations
        window.applyWebViewCustomizations = function(force = false) {
          const now = Date.now();
          
          // Prevent concurrent execution
          if (customizationState.isRunning && !force) {
            return;
          }
          
          // Throttle để tránh spam
          if (!force && (now - customizationState.lastApplied) < 10) {
            return;
          }
          
          customizationState.isRunning = true;
          customizationState.lastApplied = now;
          
          try {
            ${_generateCustomizationLogic(config)}
            customizationState.applied = true;
            customizationState.retryCount = 0;
          } catch (e) {
            console.error('Customization error:', e);
            
            // Retry with exponential backoff
            if (customizationState.retryCount < customizationState.maxRetries) {
              customizationState.retryCount++;
              setTimeout(() => {
                window.applyWebViewCustomizations(true);
              }, Math.min(1000, customizationState.retryCount * 100));
            }
          } finally {
            customizationState.isRunning = false;
          }
        };
        
        // Multi-strategy application
        function applyWithMultipleStrategies() {
          // Strategy 1: Immediate apply
          window.applyWebViewCustomizations(true);
          
          // Strategy 2: RequestAnimationFrame apply
          if (window.requestAnimationFrame) {
            requestAnimationFrame(() => {
              window.applyWebViewCustomizations();
            });
          }
          
          // Strategy 3: Multiple timeouts
          const delays = [0, 10, 25, 50, 100, 200, 500, 1000];
          delays.forEach(delay => {
            setTimeout(() => {
              window.applyWebViewCustomizations();
            }, delay);
          });
        }
        
        // DOM Ready detection và application
        function handleDOMReady() {
          applyWithMultipleStrategies();
          setupAdvancedObservers();
        }
        
        // Setup advanced observers cho dynamic content
        function setupAdvancedObservers() {
          // Enhanced Mutation Observer với immediate response
          let observerTimeout;
          const observer = new MutationObserver(function(mutations) {
            let needsImmediate = false;
            let needsDelayed = false;
            
            mutations.forEach(function(mutation) {
              if (mutation.type === 'childList' && mutation.addedNodes.length > 0) {
                mutation.addedNodes.forEach(node => {
                  if (node.nodeType === 1) { // Element node
                    const element = node;
                    
                    // Check if it's high priority (ads, etc.)
                    if (element.className && (
                        element.className.includes('ad') ||
                        element.className.includes('ads') ||
                        element.className.includes('sponsor') ||
                        element.className.includes('popup')
                      )) {
                      needsImmediate = true;
                    } else {
                      needsDelayed = true;
                    }
                  }
                });
              } else if (mutation.type === 'attributes') {
                if (['style', 'class', 'id'].includes(mutation.attributeName)) {
                  needsDelayed = true;
                }
              }
            });
            
            if (needsImmediate) {
              // Apply immediately for ads
              window.applyWebViewCustomizations();
            }
            
            if (needsDelayed) {
              clearTimeout(observerTimeout);
              observerTimeout = setTimeout(() => {
                window.applyWebViewCustomizations();
              }, 20);
            }
          });
          
          // Start observing when body is available
          function startObserving() {
            if (document.body) {
              observer.observe(document.body, { 
                childList: true, 
                subtree: true,
                attributes: true,
                attributeFilter: ['style', 'class', 'id', 'src']
              });
            } else {
              setTimeout(startObserving, 10);
            }
          }
          
          startObserving();
          
          // Intersection Observer cho lazy content
          if ('IntersectionObserver' in window) {
            const intersectionObserver = new IntersectionObserver((entries) => {
              entries.forEach(entry => {
                if (entry.isIntersecting) {
                  setTimeout(() => window.applyWebViewCustomizations(), 10);
                }
              });
            }, { threshold: 0.1 });
            
            // Observe potential containers
            setTimeout(() => {
              document.querySelectorAll('div, section, article, main, aside').forEach(el => {
                intersectionObserver.observe(el);
              });
            }, 100);
          }
        }
        
        // Apply customizations based on document state
        if (document.readyState === 'loading') {
          // Document still loading
          document.addEventListener('DOMContentLoaded', handleDOMReady);
          document.addEventListener('readystatechange', () => {
            if (document.readyState === 'interactive' || document.readyState === 'complete') {
              handleDOMReady();
            }
          });
        } else {
          // Document already loaded
          handleDOMReady();
        }
        
        // Backup application
        setTimeout(handleDOMReady, 50);
        
        // Handle window load event
        window.addEventListener('load', () => {
          setTimeout(() => window.applyWebViewCustomizations(true), 100);
        });
        
        // Handle các events có thể thay đổi content
        ['resize', 'scroll', 'focus', 'blur'].forEach(eventType => {
          window.addEventListener(eventType, () => {
            setTimeout(() => window.applyWebViewCustomizations(), 50);
          }, { passive: true });
        });
        
        // Override common DOM methods để catch dynamic additions
        ${config.hideAds ? '''
          // Override appendChild để catch dynamic ads
          const originalAppendChild = Node.prototype.appendChild;
          Node.prototype.appendChild = function(child) {
            const result = originalAppendChild.call(this, child);
            
            if (child.nodeType === 1) {
              setTimeout(() => window.applyWebViewCustomizations(), 5);
            }
            
            return result;
          };
          
          // Override innerHTML để catch dynamic content
          const originalInnerHTMLSetter = Object.getOwnPropertyDescriptor(Element.prototype, 'innerHTML').set;
          Object.defineProperty(Element.prototype, 'innerHTML', {
            set: function(value) {
              originalInnerHTMLSetter.call(this, value);
              setTimeout(() => window.applyWebViewCustomizations(), 5);
            },
            get: Object.getOwnPropertyDescriptor(Element.prototype, 'innerHTML').get
          });
        ''' : ''}
        
      })();
    ''';
  }

  String _generateCustomizationLogic(WebViewConfig config) {
    final parts = <String>[];

    // Enhanced hide selectors với multiple hiding methods
    if (config.hideSelectors.isNotEmpty) {
      final selectors = config.hideSelectors.map((s) => "'$s'").join(', ');
      parts.add('''
        // Hide selectors với aggressive approach
        const hideSelectors = [$selectors];
        hideSelectors.forEach(selector => {
          try {
            const elements = document.querySelectorAll(selector);
            elements.forEach(el => {
              // Multiple hiding techniques để đảm bảo effectiveness
              el.style.setProperty('display', 'none', 'important');
              el.style.setProperty('visibility', 'hidden', 'important');
              el.style.setProperty('opacity', '0', 'important');
              el.style.setProperty('height', '0', 'important');
              el.style.setProperty('width', '0', 'important');
              el.style.setProperty('overflow', 'hidden', 'important');
              el.style.setProperty('position', 'absolute', 'important');
              el.style.setProperty('left', '-9999px', 'important');
              el.style.setProperty('pointer-events', 'none', 'important');
              
              // Mark element as hidden
              el.setAttribute('data-webview-hidden', 'true');
            });
          } catch (e) {
            console.warn('Failed to hide selector:', selector, e);
          }
        });
      ''');
    }

    // Enhanced custom styles với higher priority
    if (config.customStyles.isNotEmpty) {
      final cssRules = config.customStyles.entries
          .map((e) => '${e.key} { ${e.value} }')
          .join('\n');
      parts.add('''
        // Apply custom styles với high priority
        let customStyleElement = document.getElementById('webview-custom-styles');
        if (!customStyleElement) {
          customStyleElement = document.createElement('style');
          customStyleElement.id = 'webview-custom-styles';
          customStyleElement.type = 'text/css';
          
          const head = document.head || document.getElementsByTagName('head')[0];
          if (head) {
            head.appendChild(customStyleElement);
          }
        }
        
        const customCSS = `$cssRules`;
        if (customStyleElement.styleSheet) {
          customStyleElement.styleSheet.cssText = customCSS;
        } else {
          customStyleElement.textContent = customCSS;
        }
      ''');
    }

    // Super aggressive ad blocking
    if (config.hideAds) {
      parts.add('''
        // Comprehensive ad blocking với immediate action
        const adSelectors = [
          '.advertisement', '.ads', '.google-ads', '.sponsored', '.ad-banner',
          '.adsense', '.adsbygoogle', '.ad-wrapper', '.ad-content', '.ad-slot',
          '.advertising', '.sponsor', '.promoted', '.promotion', '.popup',
          '[class*="ad-"]', '[id*="ad-"]', '[class*="ads-"]', '[id*="ads-"]',
          '[class*="sponsor"]', '[id*="sponsor"]', '[class*="popup"]', '[id*="popup"]',
          'iframe[src*="ads"]', 'iframe[src*="doubleclick"]', 'iframe[src*="googlesyndication"]'
        ];
        
        adSelectors.forEach(selector => {
          try {
            const elements = document.querySelectorAll(selector);
            elements.forEach(el => {
              // Complete removal strategy
              el.style.setProperty('display', 'none', 'important');
              el.style.setProperty('visibility', 'hidden', 'important');
              el.style.setProperty('opacity', '0', 'important');
              el.style.setProperty('height', '0', 'important');
              el.style.setProperty('width', '0', 'important');
              el.style.setProperty('overflow', 'hidden', 'important');
              el.style.setProperty('position', 'absolute', 'important');
              el.style.setProperty('left', '-9999px', 'important');
              el.setAttribute('data-ad-blocked', 'true');
              
              // Remove từ DOM sau delay ngắn
              setTimeout(() => {
                if (el.parentNode) {
                  el.parentNode.removeChild(el);
                }
              }, 10);
            });
          } catch (e) {
            console.warn('Ad blocking failed for selector:', selector, e);
          }
        });
        
        // Block ad scripts và iframes
        if (window.googletag) {
          try {
            window.googletag.destroySlots();
          } catch (e) {}
        }
        
        if (window.adsbygoogle) {
          window.adsbygoogle = [];
        }
        
        // Override createElement để block ad elements
        const originalCreateElement = document.createElement;
        document.createElement = function(tagName) {
          const element = originalCreateElement.call(this, tagName);
          
          if (tagName.toLowerCase() === 'script') {
            const originalSetAttribute = element.setAttribute;
            element.setAttribute = function(name, value) {
              if (name === 'src' && value && (
                value.includes('googlesyndication') ||
                value.includes('doubleclick') ||
                value.includes('googleadservices') ||
                value.includes('/ads/') ||
                value.includes('.ads.')
              )) {
                console.log('Blocked ad script:', value);
                return;
              }
              originalSetAttribute.call(this, name, value);
            };
          } else if (tagName.toLowerCase() === 'iframe') {
            const originalSetAttribute = element.setAttribute;
            element.setAttribute = function(name, value) {
              if (name === 'src' && value && (
                value.includes('ads') || 
                value.includes('doubleclick') || 
                value.includes('googlesyndication')
              )) {
                console.log('Blocked ad iframe:', value);
                element.style.display = 'none';
                return;
              }
              originalSetAttribute.call(this, name, value);
            };
          }
          
          return element;
        };
      ''');
    }

    return parts.join('\n\n');
  }

  Future<void> _injectFallbackScript(
    WebViewController controller,
    WebViewConfig config,
  ) async {
    try {
      final fallbackScript = '''
        (function() {
          'use strict';
          
          function applyFallbackCustomizations() {
            try {
              // Basic hide selectors
              ${config.hideSelectors.map((selector) => '''
                document.querySelectorAll('$selector').forEach(el => {
                  el.style.setProperty('display', 'none', 'important');
                  el.style.setProperty('visibility', 'hidden', 'important');
                });
              ''').join('\n')}
              
              // Basic ad blocking
              const basicAdSelectors = ['.advertisement', '.ads', '.google-ads', '.sponsored'];
              basicAdSelectors.forEach(selector => {
                document.querySelectorAll(selector).forEach(el => {
                  el.style.display = 'none';
                  el.remove();
                });
              });
              
              // Apply custom styles
              ${config.customStyles.isNotEmpty ? '''
                const style = document.createElement('style');
                style.innerHTML = `${config.customStyles.entries.map((e) => '${e.key} { ${e.value} }').join('\n')}`;
                if (document.head) {
                  document.head.appendChild(style);
                }
              ''' : ''}
              
            } catch (e) {
              console.error('Fallback customizations error:', e);
            }
          }
          
          // Apply fallback customizations
          applyFallbackCustomizations();
          
          // Re-apply with delays
          setTimeout(applyFallbackCustomizations, 100);
          setTimeout(applyFallbackCustomizations, 500);
          setTimeout(applyFallbackCustomizations, 1000);
          
          // Setup basic observer
          if (window.MutationObserver) {
            const observer = new MutationObserver(function() {
              setTimeout(applyFallbackCustomizations, 50);
            });
            
            if (document.body) {
              observer.observe(document.body, { childList: true, subtree: true });
            }
          }
          
        })();
      ''';

      await controller.runJavaScript(fallbackScript);
    } catch (e) {
      // Final silent fail
    }
  }
}
