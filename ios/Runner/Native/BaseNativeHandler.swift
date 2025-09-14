import Flutter
import UIKit

protocol BaseNativeHandler {
    var channelName: String { get }
    var eventChannels: [String: String] { get }
    
    func initialize()
    func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult)
    func getStreamHandler(eventName: String) -> (any FlutterStreamHandler & NSObjectProtocol)?
    func onDestroy()
}

class AbstractNativeHandler: NSObject, BaseNativeHandler {
    let flutterEngine: FlutterEngine
    let context: AppDelegate
    
    var methodChannel: FlutterMethodChannel!
    var eventChannelMap: [String: FlutterEventChannel] = [:]
    
    // Abstract properties - must be overridden
    var channelName: String {
        fatalError("Must override channelName in \(type(of: self))")
    }
    
    var eventChannels: [String: String] {
        return [:]
    }
    
    init(flutterEngine: FlutterEngine, context: AppDelegate) {
        self.flutterEngine = flutterEngine
        self.context = context
        super.init()
    }
    
    func initialize() {
        setupMethodChannel()
        setupEventChannels()
        print("🚀 Initialized handler: \(channelName)")
    }
    
    private func setupMethodChannel() {
        methodChannel = FlutterMethodChannel(
            name: channelName,
            binaryMessenger: flutterEngine.binaryMessenger
        )
        
        methodChannel.setMethodCallHandler { [weak self] call, result in
            guard let self = self else { return }
            print("📞 Method call: \(call.method) on \(self.channelName)")
            self.handleMethodCall(call, result: result)
        }
    }
    
    private func setupEventChannels() {
        eventChannels.forEach { (name, channel) in
            let eventChannel = FlutterEventChannel(
                name: channel,
                binaryMessenger: flutterEngine.binaryMessenger
            )
            eventChannelMap[name] = eventChannel
            
            // Fixed: Properly handle FlutterStreamHandler
            if let streamHandler = getStreamHandler(eventName: name) {
                eventChannel.setStreamHandler(streamHandler)
                print("🔄 Setup event channel: \(channel)")
            }
        }
    }
    
    // Abstract methods - must be overridden
    func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        fatalError("Must override handleMethodCall in \(type(of: self))")
    }
    
    func getStreamHandler(eventName: String) -> (any FlutterStreamHandler & NSObjectProtocol)? {
        return nil
    }
    
    func onDestroy() {
        eventChannelMap.removeAll()
        print("💥 Destroyed handler: \(channelName)")
    }
}
