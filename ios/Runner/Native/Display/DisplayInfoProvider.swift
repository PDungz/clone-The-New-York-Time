import UIKit

class DisplayInfoProvider {
    
    func getDisplayInfo() -> [String: Any] {
        let screen = UIScreen.main
        let bounds = screen.bounds
        let scale = screen.scale
        let safeArea = getSafeAreaInsets()
        
        let info: [String: Any] = [
            "themeMode": getThemeMode(),
            "isDarkMode": isDarkMode(),
            "screenBrightness": Double(screen.brightness),
            "fontSize": getDynamicTypeSize(),
            "orientation": getOrientationString(),
            "screenWidth": Double(bounds.width),
            "screenHeight": Double(bounds.height),
            "screenInches": getScreenInches(),
            "devicePixelRatio": Double(scale),
            "statusBarHeight": Double(safeArea.top),
            "navigationBarHeight": Double(safeArea.bottom),
            "isLargeTextEnabled": isLargeTextEnabled(),
            "isReduceMotionEnabled": UIAccessibility.isReduceMotionEnabled,
            "languageCode": getLanguageCode()
        ]
        
        print("📱 Display info: \(info)")
        return info
    }
    
    func getRefreshRate() -> Double {
        if #available(iOS 10.3, *) {
            return Double(UIScreen.main.maximumFramesPerSecond)
        }
        return 60.0
    }
    
    func setBrightness(_ brightness: Double) -> Bool {
        let clampedBrightness = max(0.0, min(1.0, brightness))
        UIScreen.main.brightness = CGFloat(clampedBrightness)
        print("🔆 Set brightness to: \(clampedBrightness)")
        return true
    }
    
    func isPortrait() -> Bool {
        return getOrientationString() == "portrait"
    }
    
    func isLandscape() -> Bool {
        return getOrientationString() == "landscape"
    }
    
    func isDarkMode() -> Bool {
        if #available(iOS 12.0, *) {
            // Use view controller's trait collection instead of current
            if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                return rootViewController.traitCollection.userInterfaceStyle == .dark
            }
        }
        return false
    }
    
    func getScreenSize() -> [String: Double] {
        let bounds = UIScreen.main.bounds
        return [
            "width": Double(bounds.width),
            "height": Double(bounds.height)
        ]
    }
    
    func getScreenInches() -> Double {
        // Simplified - just return default value
        return 6.1
    }
    
    // MARK: - Helper Methods
    
    private func getThemeMode() -> String {
        if #available(iOS 12.0, *) {
            // Use view controller's trait collection instead of current
            if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                switch rootViewController.traitCollection.userInterfaceStyle {
                case .dark:
                    return "dark"
                case .light:
                    return "light"
                case .unspecified:
                    return "auto"
                @unknown default:
                    return "auto"
                }
            }
        }
        return "light"
    }
    
    private func getDynamicTypeSize() -> Double {
        let category = UIApplication.shared.preferredContentSizeCategory
        let baseFontSize: Double = 17.0
        
        switch category {
        case .extraSmall:
            return baseFontSize * 0.823
        case .small:
            return baseFontSize * 0.882
        case .medium:
            return baseFontSize * 0.941
        case .large:
            return baseFontSize
        case .extraLarge:
            return baseFontSize * 1.118
        case .extraExtraLarge:
            return baseFontSize * 1.235
        case .extraExtraExtraLarge:
            return baseFontSize * 1.353
        default:
            // Handle accessibility categories with version check
            if #available(iOS 10.0, *) {
                switch category {
                case .accessibilityMedium:
                    return baseFontSize * 1.786
                case .accessibilityLarge:
                    return baseFontSize * 2.143
                case .accessibilityExtraLarge:
                    return baseFontSize * 2.643
                case .accessibilityExtraExtraLarge:
                    return baseFontSize * 3.143
                case .accessibilityExtraExtraExtraLarge:
                    return baseFontSize * 3.571
                default:
                    return baseFontSize
                }
            } else {
                return baseFontSize
            }
        }
    }
    
    private func getOrientationString() -> String {
        let orientation = UIDevice.current.orientation
        
        // Check if orientation is valid first
        if orientation.isValidInterfaceOrientation {
            switch orientation {
            case .portrait, .portraitUpsideDown:
                return "portrait"
            case .landscapeLeft, .landscapeRight:
                return "landscape"
            default:
                break
            }
        }
        
        // Fallback to status bar orientation (compatible with all iOS versions)
        let statusBarOrientation = UIApplication.shared.statusBarOrientation
        return statusBarOrientation.isLandscape ? "landscape" : "portrait"
    }
    
    private func getSafeAreaInsets() -> UIEdgeInsets {
        if #available(iOS 11.0, *) {
            // Try to get safe area from current window
            if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
                return window.safeAreaInsets
            }
        }
        
        // Fallback for older iOS versions
        return UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: - Additional Helper Methods
    
    private func getLanguageCode() -> String {
        // Fixed: Use Locale without .current
        return Locale.preferredLanguages.first?.components(separatedBy: "-").first ?? "en"
    }
    
    private func isLargeTextEnabled() -> Bool {
        let category = UIApplication.shared.preferredContentSizeCategory
        
        if #available(iOS 10.0, *) {
            return category.isAccessibilityCategory
        } else {
            // iOS 9 fallback - check manually
            switch category {
            case .accessibilityMedium,
                 .accessibilityLarge,
                 .accessibilityExtraLarge,
                 .accessibilityExtraExtraLarge,
                 .accessibilityExtraExtraExtraLarge:
                return true
            default:
                return false
            }
        }
    }
}
