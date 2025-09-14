import UIKit
import Flutter

class OrientationListener: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        startListening()
        
        // Send current orientation immediately
        let currentOrientation = getCurrentOrientation()
        events(currentOrientation)
        
        print("🔄 Started orientation listening")
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        stopListening()
        self.eventSink = nil
        print("⏹️ Stopped orientation listening")
        return nil
    }
    
    private func startListening() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationDidChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }
    
    private func stopListening() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }
    
    @objc private func orientationDidChange() {
        let orientation = getCurrentOrientation()
        print("📱 Orientation changed to: \(orientation)")
        eventSink?(orientation)
    }
    
    private func getCurrentOrientation() -> String {
        switch UIDevice.current.orientation {
        case .portrait, .portraitUpsideDown:
            return "portrait"
        case .landscapeLeft, .landscapeRight:
            return "landscape"
        default:
            // Fallback to interface orientation
            if #available(iOS 13.0, *) {
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                let orientation = windowScene?.interfaceOrientation
                return orientation?.isLandscape == true ? "landscape" : "portrait"
            } else {
                return UIApplication.shared.statusBarOrientation.isLandscape ? "landscape" : "portrait"
            }
        }
    }
}
