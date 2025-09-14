import Flutter
import UIKit

class DisplayNativeHandler: AbstractNativeHandler {
    override var channelName: String {
        return "display_service"
    }
    
    override var eventChannels: [String: String] {
        return [
            "orientation": "display_service/orientation",
            "brightness": "display_service/brightness"
        ]
    }
    
    private let provider = DisplayInfoProvider()
    private var orientationListener: OrientationListener?
    private var brightnessListener: BrightnessListener?
    
    override func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getDisplayInfo":
            let info = provider.getDisplayInfo()
            result(info)
            
        case "getRefreshRate":
            let refreshRate = provider.getRefreshRate()
            result(refreshRate)
            
        case "setBrightness":
            if let brightness = call.arguments as? Double {
                let success = provider.setBrightness(brightness)
                result(success)
            } else {
                result(FlutterError(
                    code: "INVALID_ARGUMENTS",
                    message: "Brightness must be a double value between 0.0 and 1.0",
                    details: nil
                ))
            }
            
        case "isPortrait":
            result(provider.isPortrait())
            
        case "isLandscape":
            result(provider.isLandscape())
            
        case "isDarkMode":
            result(provider.isDarkMode())
            
        case "getScreenSize":
            result(provider.getScreenSize())
            
        case "getScreenInches":
            result(provider.getScreenInches())
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    override func getStreamHandler(eventName: String) -> (any FlutterStreamHandler & NSObjectProtocol)? {
        switch eventName {
        case "orientation":
            orientationListener = OrientationListener()
            return orientationListener
        case "brightness":
            brightnessListener = BrightnessListener()
            return brightnessListener
        default:
            return nil
        }
    }
    
    override func onDestroy() {
        super.onDestroy()
        orientationListener = nil
        brightnessListener = nil
    }
}
