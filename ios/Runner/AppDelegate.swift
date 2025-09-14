import Flutter
import UIKit

import flutter_local_notifications

@main
class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FlutterLocalNotificationsPlugin.setPluginRegistrantCallback {
            (registry) in GeneratedPluginRegistrant.register(with: registry)
        }
        
        GeneratedPluginRegistrant.register(with: self)

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        }
        
        // Setup native channels safely
        if let controller = window?.rootViewController as? FlutterViewController {
            NativeChannelRegistry.setup(flutterEngine: controller.engine, context: self)
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func applicationWillTerminate(_ application: UIApplication) {
        NativeChannelRegistry.onDestroy()
        super.applicationWillTerminate(application)
    }
}
