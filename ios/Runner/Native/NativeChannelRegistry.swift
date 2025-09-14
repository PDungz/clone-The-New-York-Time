import Flutter
import UIKit

class NativeChannelRegistry {
    private static var handlers: [BaseNativeHandler] = []
    
    static func setup(flutterEngine: FlutterEngine, context: AppDelegate) {
        // Register display handler
        registerHandler(DisplayNativeHandler(flutterEngine: flutterEngine, context: context))
        
        // Register device handler
        registerHandler(DeviceNativeHandler(flutterEngine: flutterEngine, context: context))
        
        // Initialize all handlers
        handlers.forEach { $0.initialize() }
        
        print("✅ Native Channel Registry initialized with \(handlers.count) handlers")
    }
    
    private static func registerHandler(_ handler: BaseNativeHandler) {
        handlers.append(handler)
        print("📱 Registered handler: \(handler.channelName)")
    }
    
    static func onDestroy() {
        print("🔥 Destroying Native Channel Registry")
        handlers.forEach { $0.onDestroy() }
        handlers.removeAll()
    }
}
