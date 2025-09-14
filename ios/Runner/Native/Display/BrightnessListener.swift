import UIKit
import Flutter

class BrightnessListener: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        startListening()
        
        // Send current brightness immediately
        let currentBrightness = Double(UIScreen.main.brightness)
        events(currentBrightness)
        
        print("🔆 Started brightness listening")
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        stopListening()
        self.eventSink = nil
        print("⏹️ Stopped brightness listening")
        return nil
    }
    
    private func startListening() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(brightnessDidChange),
            name: UIScreen.brightnessDidChangeNotification,
            object: nil
        )
    }
    
    private func stopListening() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIScreen.brightnessDidChangeNotification,
            object: nil
        )
    }
    
    @objc private func brightnessDidChange() {
        let brightness = Double(UIScreen.main.brightness)
        print("🔆 Brightness changed to: \(brightness)")
        eventSink?(brightness)
    }
}
