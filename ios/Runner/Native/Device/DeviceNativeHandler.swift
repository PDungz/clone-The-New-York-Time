// ios/Runner/Native/Device/DeviceNativeHandler.swift
import Flutter
import UIKit

class DeviceNativeHandler: AbstractNativeHandler {
    override var channelName: String {
        return "device_service"
    }
    
    override var eventChannels: [String: String] {
        return [:] // Không cần event channels cho bây giờ
    }
    
    private let provider = DeviceInfoProvider()
    
    override func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getDeviceInfo":
            // Async version with location
            provider.getDeviceInfo { deviceInfo in
                DispatchQueue.main.async {
                    result(deviceInfo)
                }
            }
            
        case "getDeviceInfoSync":
            // Sync version without full location (fallback)
            let info = provider.getDeviceInfoSync()
            result(info)
            
        case "getSystemInfo":
            let info = provider.getSystemInfo()
            result(info)
            
        case "getDeviceIdentifier":
            let identifier = provider.getDeviceIdentifier()
            result(identifier)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    override func getStreamHandler(eventName: String) -> (any FlutterStreamHandler & NSObjectProtocol)? {
        return nil // Không cần stream handlers cho bây giờ
    }
}
