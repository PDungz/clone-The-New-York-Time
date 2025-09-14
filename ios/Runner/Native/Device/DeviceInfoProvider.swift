// ios/Runner/Native/Device/DeviceInfoProvider.swift
import UIKit
import CoreLocation

class DeviceInfoProvider: NSObject {
    
    private let locationManager = CLLocationManager()
    private var locationCompletion: (([String: Any]) -> Void)?
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    func getDeviceInfo(completion: @escaping ([String: Any]) -> Void) {
        // Get basic device info first
        var deviceInfo: [String: Any] = [
            "deviceName": getDeviceName(),
            "deviceType": getDeviceType(),
            "platform": "ios",
            "platformVersion": UIDevice.current.systemVersion,
            "appVersion": getAppVersion(),
            "deviceIdentifier": getDeviceIdentifier(),
            "pushToken": NSNull(),
            "screenResolution": getScreenResolution(),
            "timezone": getTimezone(),
            "language": getLanguageCode(),
            "isPushEnabled": false,
            "isActive": true,
            "isPrimary": isPrimaryDevice(),
            "status": "ACTIVE"
        ]
        
        // Get location info asynchronously
        getLocationInfo { locationData in
            deviceInfo["location"] = locationData
            print("📱 Device info collected: \(deviceInfo)")
            completion(deviceInfo)
        }
    }
    
    // Synchronous version without location (for backward compatibility)
    func getDeviceInfoSync() -> [String: Any] {
        let deviceInfo: [String: Any] = [
            "deviceName": getDeviceName(),
            "deviceType": getDeviceType(),
            "platform": "ios",
            "platformVersion": UIDevice.current.systemVersion,
            "appVersion": getAppVersion(),
            "deviceIdentifier": getDeviceIdentifier(),
            "pushToken": NSNull(),
            "screenResolution": getScreenResolution(),
            "timezone": getTimezone(),
            "language": getLanguageCode(),
            "isPushEnabled": false,
            "isActive": true,
            "isPrimary": isPrimaryDevice(),
            "status": "ACTIVE",
            "location": getLocationInfoSync()
        ]
        
        print("📱 Device info collected (sync): \(deviceInfo)")
        return deviceInfo
    }
    
    func getSystemInfo() -> [String: Any] {
        return [
            "deviceName": getDeviceName(),
            "deviceType": getDeviceType(),
            "platform": "ios",
            "platformVersion": UIDevice.current.systemVersion,
            "screenResolution": getScreenResolution(),
            "timezone": getTimezone(),
            "language": getLanguageCode(),
            "isPrimary": isPrimaryDevice()
        ]
    }
    
    func getDeviceIdentifier() -> String {
        if let idfv = UIDevice.current.identifierForVendor?.uuidString {
            return idfv
        }
        
        let key = "device_identifier"
        if let stored = UserDefaults.standard.string(forKey: key) {
            return stored
        }
        
        let newIdentifier = UUID().uuidString
        UserDefaults.standard.set(newIdentifier, forKey: key)
        return newIdentifier
    }
    
    // MARK: - Location Methods
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func getLocationInfo(completion: @escaping ([String: Any]) -> Void) {
        guard CLLocationManager.locationServicesEnabled() else {
            completion(getDefaultLocationInfo())
            return
        }
        
        let authStatus = CLLocationManager.authorizationStatus()
        
        switch authStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            getCurrentLocation(completion: completion)
        case .notDetermined:
            locationCompletion = completion
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            getIPBasedLocation(completion: completion)
        @unknown default:
            completion(getDefaultLocationInfo())
        }
    }
    
    private func getCurrentLocation(completion: @escaping ([String: Any]) -> Void) {
        locationCompletion = completion
        locationManager.requestLocation()
    }
    
    private func getLocationDetails(from location: CLLocation, completion: @escaping ([String: Any]) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            var locationInfo: [String: Any] = [
                "ipAddress": self?.getLocalIPAddress() ?? "Unknown",
                "latitude": location.coordinate.latitude,
                "longitude": location.coordinate.longitude
            ]
            
            if let placemark = placemarks?.first {
                locationInfo["country"] = placemark.country ?? "Unknown"
                locationInfo["city"] = placemark.locality ?? placemark.administrativeArea ?? "Unknown"
                completion(locationInfo)
            } else {
                self?.getIPBasedLocationDetails { ipLocationInfo in
                    locationInfo["country"] = ipLocationInfo["country"] ?? "Unknown"
                    locationInfo["city"] = ipLocationInfo["city"] ?? "Unknown"
                    completion(locationInfo)
                }
            }
        }
    }
    
    private func getIPBasedLocation(completion: @escaping ([String: Any]) -> Void) {
        getIPBasedLocationDetails(completion: completion)
    }
    
    private func getIPBasedLocationDetails(completion: @escaping ([String: Any]) -> Void) {
        guard let url = URL(string: "https://ipapi.co/json/") else {
            completion(getDefaultLocationInfo())
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(self?.getDefaultLocationInfo() ?? [:])
                }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let locationInfo: [String: Any] = [
                        "ipAddress": json["ip"] as? String ?? self?.getLocalIPAddress() ?? "Unknown",
                        "country": json["country_name"] as? String ?? "Unknown",
                        "city": json["city"] as? String ?? "Unknown",
                        "latitude": json["latitude"] as? Double ?? 0.0,
                        "longitude": json["longitude"] as? Double ?? 0.0
                    ]
                    
                    DispatchQueue.main.async {
                        completion(locationInfo)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(self?.getDefaultLocationInfo() ?? [:])
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(self?.getDefaultLocationInfo() ?? [:])
                }
            }
        }
        
        task.resume()
    }
    
    private func getLocationInfoSync() -> [String: Any] {
        return [
            "ipAddress": getLocalIPAddress(),
            "country": getCountryFromLocale(),
            "city": "Unknown",
            "latitude": 0.0,
            "longitude": 0.0
        ]
    }
    
    private func getDefaultLocationInfo() -> [String: Any] {
        return [
            "ipAddress": getLocalIPAddress(),
            "country": "Unknown",
            "city": "Unknown",
            "latitude": 0.0,
            "longitude": 0.0
        ]
    }
    
    private func getLocalIPAddress() -> String {
        var address = "192.168.1.1" // Default fallback
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        
        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else { 
            return address 
        }
        
        defer { freeifaddrs(ifaddr) }
        
        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let flags = Int32(ptr.pointee.ifa_flags)
            let addr = ptr.pointee.ifa_addr.pointee
            
            if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                if addr.sa_family == UInt8(AF_INET) {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if getnameinfo(ptr.pointee.ifa_addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST) == 0 {
                        let ipAddress = String(cString: hostname)
                        if !ipAddress.hasPrefix("127.") {
                            address = ipAddress
                            break
                        }
                    }
                }
            }
        }
        
        return address
    }
    
    private func getCountryFromLocale() -> String {
        if #available(iOS 16.0, *) {
            return Locale.current.region?.identifier ?? "Unknown"
        } else {
            return Locale.current.regionCode ?? "Unknown"
        }
    }
    
    // MARK: - Helper Methods
    
    private func getDeviceName() -> String {
        return UIDevice.current.name.isEmpty ? getDeviceModel() : UIDevice.current.name
    }
    
    private func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
            }
        }
        
        let deviceMapping: [String: String] = [
            "iPhone14,7": "iPhone 14",
            "iPhone14,8": "iPhone 14 Plus",
            "iPhone15,2": "iPhone 14 Pro",
            "iPhone15,3": "iPhone 14 Pro Max",
            "iPhone15,4": "iPhone 15",
            "iPhone15,5": "iPhone 15 Plus",
            "iPhone16,1": "iPhone 15 Pro",
            "iPhone16,2": "iPhone 15 Pro Max",
            "iPhone17,3": "iPhone 16",
            "iPhone17,4": "iPhone 16 Plus",
            "iPhone17,1": "iPhone 16 Pro",
            "iPhone17,2": "iPhone 16 Pro Max",
        ]
        
        return deviceMapping[modelCode ?? ""] ?? (modelCode ?? "Unknown Device")
    }
    
    private func getDeviceType() -> String {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return "MOBILE"
        case .pad:
            return "TABLET"
        case .tv:
            return "TV"
        case .mac:
            return "DESKTOP"
        @unknown default:
            return "UNKNOWN"
        }
    }
    
    private func getAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    private func getScreenResolution() -> String {
        let screen = UIScreen.main
        let bounds = screen.bounds
        let scale = screen.scale
        
        let width = Int(bounds.width * scale)
        let height = Int(bounds.height * scale)
        
        return "\(width)x\(height)"
    }
    
    private func getTimezone() -> String {
        return TimeZone.current.identifier
    }
    
    private func getLanguageCode() -> String {
        return Locale.preferredLanguages.first?.components(separatedBy: "-").first ?? "en"
    }
    
    private func isPrimaryDevice() -> Bool {
        let key = "is_primary_device"
        if UserDefaults.standard.object(forKey: key) == nil {
            UserDefaults.standard.set(true, forKey: key)
            return true
        }
        return UserDefaults.standard.bool(forKey: key)
    }
}

// MARK: - CLLocationManagerDelegate
extension DeviceInfoProvider: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, let completion = locationCompletion else { 
            return 
        }
        
        getLocationDetails(from: location, completion: completion)
        locationCompletion = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location error: \(error)")
        if let completion = locationCompletion {
            completion(getDefaultLocationInfo())
            locationCompletion = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard let completion = locationCompletion else { return }
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            getCurrentLocation(completion: completion)
        case .denied, .restricted:
            getIPBasedLocation(completion: completion)
            locationCompletion = nil
        default:
            break
        }
    }
}