package com.nytimes.news_app.native.device

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.location.LocationManager
import android.location.LocationListener
import android.location.Location
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.util.DisplayMetrics
import android.util.Log
import android.view.WindowManager
import androidx.core.app.ActivityCompat
import kotlinx.coroutines.*
import org.json.JSONObject
import java.io.BufferedReader
import java.io.InputStreamReader
import java.net.HttpURLConnection
import java.net.URL
import java.security.MessageDigest
import java.util.*
import kotlin.math.sqrt

class DeviceInfoProvider(private val context: Context) {

    private val TAG = "DeviceInfoProvider"

    fun getDeviceInfo(callback: (Map<String, Any?>) -> Unit) {
        // Get basic device info first
        val deviceInfo = mutableMapOf<String, Any?>(
            "deviceName" to getDeviceName(),
            "deviceType" to getDeviceType(),
            "platform" to "android",
            "platformVersion" to Build.VERSION.RELEASE,
            "appVersion" to getAppVersion(),
            "deviceIdentifier" to getDeviceIdentifier(),
            "pushToken" to null,
            "screenResolution" to getScreenResolution(),
            "timezone" to getTimezone(),
            "language" to getLanguageCode(),
            "isPushEnabled" to false,
            "isActive" to true,
            "isPrimary" to isPrimaryDevice(),
            "status" to "ACTIVE"
        )

        // Get location info asynchronously with improved handling
        getLocationInfoImproved { locationData ->
            deviceInfo["location"] = locationData
            Log.d(TAG, "📱 Android Device info collected: $deviceInfo")
            callback(deviceInfo)
        }
    }

    fun getDeviceInfoSync(): Map<String, Any?> {
        val deviceInfo = mapOf<String, Any?>(
            "deviceName" to getDeviceName(),
            "deviceType" to getDeviceType(),
            "platform" to "android",
            "platformVersion" to Build.VERSION.RELEASE,
            "appVersion" to getAppVersion(),
            "deviceIdentifier" to getDeviceIdentifier(),
            "pushToken" to null,
            "screenResolution" to getScreenResolution(),
            "timezone" to getTimezone(),
            "language" to getLanguageCode(),
            "isPushEnabled" to false,
            "isActive" to true,
            "isPrimary" to isPrimaryDevice(),
            "status" to "ACTIVE",
            "location" to getLocationInfoSync()
        )

        Log.d(TAG, "📱 Android Device info collected (sync): $deviceInfo")
        return deviceInfo
    }

    fun getSystemInfo(): Map<String, Any> {
        return mapOf(
            "deviceName" to getDeviceName(),
            "deviceType" to getDeviceType(),
            "platform" to "android",
            "platformVersion" to Build.VERSION.RELEASE,
            "screenResolution" to getScreenResolution(),
            "timezone" to getTimezone(),
            "language" to getLanguageCode(),
            "isPrimary" to isPrimaryDevice()
        )
    }

    // MARK: - Improved Location Methods

    private fun getLocationInfoImproved(callback: (Map<String, Any>) -> Unit) {
        Log.d(TAG, "🌍 Starting location info collection...")

        // First, always try IP-based location (works in emulator)
        getIPBasedLocationImproved { ipLocationInfo ->
            Log.d(TAG, "🌐 IP-based location result: $ipLocationInfo")
            
            // If IP location is successful, use it
            if (ipLocationInfo["country"] != "Unknown" || ipLocationInfo["city"] != "Unknown") {
                callback(ipLocationInfo)
                return@getIPBasedLocationImproved
            }

            // If IP failed, try GPS location
            tryGPSLocation { gpsLocationInfo ->
                if (gpsLocationInfo != null) {
                    Log.d(TAG, "📍 GPS location result: $gpsLocationInfo")
                    callback(gpsLocationInfo)
                } else {
                    Log.d(TAG, "⚠️ All location methods failed, using fallback")
                    callback(getFallbackLocationInfo())
                }
            }
        }
    }

    private fun getIPBasedLocationImproved(callback: (Map<String, Any>) -> Unit) {
        Log.d(TAG, "🌐 Attempting IP-based location...")
        
        GlobalScope.launch(Dispatchers.IO) {
            var result: Map<String, Any>? = null
            
            // Try multiple IP location services
            val services = listOf(
                "http://ip-api.com/json/",  // Better for emulator
                "https://ipapi.co/json/",
                "http://ipinfo.io/json"
            )

            for (service in services) {
                try {
                    Log.d(TAG, "🔗 Trying service: $service")
                    val locationInfo = fetchFromService(service)
                    if (locationInfo != null && locationInfo["country"] != "Unknown") {
                        result = locationInfo
                        Log.d(TAG, "✅ Success with service: $service")
                        break
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "❌ Failed service $service: ${e.message}")
                }
            }

            GlobalScope.launch(Dispatchers.Main) {
                callback(result ?: getDefaultLocationInfo())
            }
        }
    }

    private fun fetchFromService(serviceUrl: String): Map<String, Any>? {
        return try {
            val url = URL(serviceUrl)
            val connection = url.openConnection() as HttpURLConnection
            connection.requestMethod = "GET"
            connection.connectTimeout = 8000
            connection.readTimeout = 8000
            connection.setRequestProperty("User-Agent", "Mozilla/5.0 (Android)")

            if (connection.responseCode == HttpURLConnection.HTTP_OK) {
                val reader = BufferedReader(InputStreamReader(connection.inputStream))
                val response = reader.readText()
                reader.close()

                Log.d(TAG, "📄 Response from $serviceUrl: $response")

                val json = JSONObject(response)
                val locationInfo = when {
                    serviceUrl.contains("ip-api.com") -> mapOf(
                        "ipAddress" to json.optString("query", getLocalIPAddress()),
                        "country" to json.optString("country", "Unknown"),
                        "city" to json.optString("city", "Unknown"),
                        "latitude" to json.optDouble("lat", 0.0),
                        "longitude" to json.optDouble("lon", 0.0)
                    )
                    serviceUrl.contains("ipapi.co") -> mapOf(
                        "ipAddress" to json.optString("ip", getLocalIPAddress()),
                        "country" to json.optString("country_name", "Unknown"),
                        "city" to json.optString("city", "Unknown"),
                        "latitude" to json.optDouble("latitude", 0.0),
                        "longitude" to json.optDouble("longitude", 0.0)
                    )
                    serviceUrl.contains("ipinfo.io") -> mapOf(
                        "ipAddress" to json.optString("ip", getLocalIPAddress()),
                        "country" to json.optString("country", "Unknown"),
                        "city" to json.optString("city", "Unknown"),
                        "latitude" to 0.0, // ipinfo.io doesn't provide coords in free tier
                        "longitude" to 0.0
                    )
                    else -> null
                }

                locationInfo
            } else {
                Log.e(TAG, "❌ HTTP error ${connection.responseCode} for $serviceUrl")
                null
            }
        } catch (e: Exception) {
            Log.e(TAG, "❌ Exception fetching from $serviceUrl: ${e.message}")
            null
        }
    }

    private fun tryGPSLocation(callback: (Map<String, Any>?) -> Unit) {
        try {
            val locationManager = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
            
            // Check if location services are enabled
            if (!locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER) && 
                !locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)) {
                Log.d(TAG, "📍 Location services disabled")
                callback(null)
                return
            }

            // Check permissions
            if (ActivityCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED &&
                ActivityCompat.checkSelfPermission(context, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                Log.d(TAG, "📍 No location permissions")
                callback(null)
                return
            }

            Log.d(TAG, "📍 Trying GPS location...")

            // Try to get last known location first
            val lastKnownLocation = locationManager.getLastKnownLocation(LocationManager.GPS_PROVIDER)
                ?: locationManager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER)

            if (lastKnownLocation != null) {
                Log.d(TAG, "📍 Got last known location")
                getLocationDetails(lastKnownLocation, callback)
            } else {
                Log.d(TAG, "📍 No last known location")
                callback(null)
            }
        } catch (e: SecurityException) {
            Log.e(TAG, "📍 Security exception: ${e.message}")
            callback(null)
        }
    }

    private fun getLocationDetails(location: Location, callback: (Map<String, Any>) -> Unit) {
        val locationInfo = mutableMapOf<String, Any>(
            "ipAddress" to getLocalIPAddress(),
            "latitude" to location.latitude,
            "longitude" to location.longitude
        )

        try {
            val geocoder = android.location.Geocoder(context, Locale.getDefault())
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                geocoder.getFromLocation(location.latitude, location.longitude, 1) { addresses ->
                    if (addresses.isNotEmpty()) {
                        val address = addresses[0]
                        locationInfo["country"] = address.countryName ?: "Unknown"
                        locationInfo["city"] = address.locality ?: address.adminArea ?: "Unknown"
                    } else {
                        locationInfo["country"] = "Unknown"
                        locationInfo["city"] = "Unknown"
                    }
                    callback(locationInfo)
                }
            } else {
                @Suppress("DEPRECATION")
                val addresses = geocoder.getFromLocation(location.latitude, location.longitude, 1)
                if (addresses?.isNotEmpty() == true) {
                    val address = addresses[0]
                    locationInfo["country"] = address.countryName ?: "Unknown"
                    locationInfo["city"] = address.locality ?: address.adminArea ?: "Unknown"
                } else {
                    locationInfo["country"] = "Unknown"
                    locationInfo["city"] = "Unknown"
                }
                callback(locationInfo)
            }
        } catch (e: Exception) {
            Log.e(TAG, "❌ Geocoding failed: ${e.message}")
            locationInfo["country"] = "Unknown"
            locationInfo["city"] = "Unknown"
            callback(locationInfo)
        }
    }

    private fun getLocationInfoSync(): Map<String, Any> {
        return mapOf(
            "ipAddress" to getLocalIPAddress(),
            "country" to getCountryFromLocale(),
            "city" to "Unknown",
            "latitude" to 0.0,
            "longitude" to 0.0
        )
    }

    private fun getDefaultLocationInfo(): Map<String, Any> {
        return mapOf(
            "ipAddress" to getLocalIPAddress(),
            "country" to "Unknown",
            "city" to "Unknown", 
            "latitude" to 0.0,
            "longitude" to 0.0
        )
    }

    private fun getFallbackLocationInfo(): Map<String, Any> {
        // Enhanced fallback with better emulator detection
        val isEmulator = isRunningOnEmulator()
        
        return mapOf(
            "ipAddress" to getLocalIPAddress(),
            "country" to if (isEmulator) "United States" else getCountryFromLocale(),
            "city" to if (isEmulator) "Mountain View" else "Unknown",
            "latitude" to if (isEmulator) 37.4220936 else 0.0,  // Google HQ coordinates for emulator
            "longitude" to if (isEmulator) -122.083922 else 0.0
        )
    }

    private fun isRunningOnEmulator(): Boolean {
        return (Build.FINGERPRINT.startsWith("generic") ||
                Build.FINGERPRINT.startsWith("unknown") ||
                Build.MODEL.contains("google_sdk") ||
                Build.MODEL.contains("Emulator") ||
                Build.MODEL.contains("Android SDK built for x86") ||
                Build.MANUFACTURER.contains("Genymotion") ||
                Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith("generic") ||
                "google_sdk" == Build.PRODUCT ||
                Build.PRODUCT.contains("sdk_gphone") ||
                Build.PRODUCT.contains("emulator"))
    }

    private fun getLocalIPAddress(): String {
        try {
            val networkInterfaces = java.net.NetworkInterface.getNetworkInterfaces()
            for (networkInterface in networkInterfaces) {
                val addresses = networkInterface.inetAddresses
                for (address in addresses) {
                    if (!address.isLoopbackAddress && address is java.net.Inet4Address) {
                        val ip = address.hostAddress ?: "192.168.1.1"
                        Log.d(TAG, "🌐 Found local IP: $ip")
                        return ip
                    }
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error getting local IP: ${e.message}")
        }
        return "192.168.1.1"
    }

    private fun getCountryFromLocale(): String {
        return try {
            val country = Locale.getDefault().country.takeIf { it.isNotEmpty() } ?: "Unknown"
            Log.d(TAG, "🌍 Country from locale: $country")
            country
        } catch (e: Exception) {
            "Unknown"
        }
    }

    // Rest of the methods remain the same...
    fun getDeviceIdentifier(): String {
        val androidId = Settings.Secure.getString(context.contentResolver, Settings.Secure.ANDROID_ID)
        
        if (androidId != null && androidId != "9774d56d682e549c" && androidId.isNotEmpty()) {
            return "aid_${androidId.take(16)}"
        }

        val hardwareFingerprint = generateHardwareFingerprint()
        
        if (hardwareFingerprint.isNotEmpty()) {
            return "hwf_${hardwareFingerprint}"
        }

        return getOrCreateStoredIdentifier()
    }

    private fun generateHardwareFingerprint(): String {
        try {
            val characteristics = listOf(
                Build.BOARD ?: "",
                Build.BOOTLOADER ?: "",
                Build.BRAND ?: "",
                Build.DEVICE ?: "",
                Build.DISPLAY ?: "",
                Build.FINGERPRINT ?: "",
                Build.HARDWARE ?: "",
                Build.ID ?: "",
                Build.MANUFACTURER ?: "",
                Build.MODEL ?: "",
                Build.PRODUCT ?: "",
                Build.TAGS ?: "",
                Build.TYPE ?: "",
                Build.USER ?: "",
                getScreenSpecification(),
                getCpuInfo()
            ).filter { it.isNotEmpty() }

            val combined = characteristics.joinToString("|")
            
            if (combined.length > 10) {
                return hashString(combined).take(16)
            }
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error generating hardware fingerprint: ${e.message}")
        }
        
        return ""
    }

    private fun getScreenSpecification(): String {
        return try {
            val displayMetrics = DisplayMetrics()
            val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
            @Suppress("DEPRECATION")
            windowManager.defaultDisplay.getRealMetrics(displayMetrics)
            
            "${displayMetrics.widthPixels}x${displayMetrics.heightPixels}@${displayMetrics.densityDpi}"
        } catch (e: Exception) {
            ""
        }
    }

    private fun getCpuInfo(): String {
        return try {
            listOf(
                Build.SUPPORTED_ABIS?.joinToString(",") ?: "",
                Build.CPU_ABI ?: "",
                Build.CPU_ABI2 ?: ""
            ).filter { it.isNotEmpty() }.joinToString("|")
        } catch (e: Exception) {
            ""
        }
    }

    private fun hashString(input: String): String {
        return try {
            val digest = MessageDigest.getInstance("SHA-256")
            val hashBytes = digest.digest(input.toByteArray())
            hashBytes.joinToString("") { "%02x".format(it) }
        } catch (e: Exception) {
            input.hashCode().toString()
        }
    }

    private fun getOrCreateStoredIdentifier(): String {
        val prefs = context.getSharedPreferences("device_hardware_id", Context.MODE_PRIVATE)
        val key = "hardware_device_id"
        
        val stored = prefs.getString(key, null)
        if (stored != null) {
            return "sid_${stored.take(16)}"
        }

        val newIdentifier = UUID.randomUUID().toString().replace("-", "")
        prefs.edit().putString(key, newIdentifier).apply()
        
        Log.d(TAG, "📱 Generated new stored device identifier")
        return "sid_${newIdentifier.take(16)}"
    }

    private fun getDeviceName(): String {
        val manufacturer = Build.MANUFACTURER.replaceFirstChar {
            if (it.isLowerCase()) it.titlecase(Locale.getDefault()) else it.toString()
        }
        val model = Build.MODEL

        return if (model.lowercase().startsWith(manufacturer.lowercase())) {
            model.replaceFirstChar {
                if (it.isLowerCase()) it.titlecase(Locale.getDefault()) else it.toString()
            }
        } else {
            "$manufacturer $model"
        }
    }

    private fun getDeviceType(): String {
        val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val displayMetrics = DisplayMetrics()

        @Suppress("DEPRECATION")
        windowManager.defaultDisplay.getMetrics(displayMetrics)

        val screenInches = getScreenSizeInches(displayMetrics)

        return when {
            screenInches < 6.0 -> "MOBILE"
            screenInches < 8.0 -> "MOBILE"
            screenInches < 11.0 -> "TABLET"
            else -> "TABLET"
        }
    }

    private fun getAppVersion(): String {
        return try {
            val packageInfo = context.packageManager.getPackageInfo(context.packageName, 0)
            packageInfo.versionName ?: "1.0.0"
        } catch (e: PackageManager.NameNotFoundException) {
            "1.0.0"
        }
    }

    private fun getScreenResolution(): String {
        val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val displayMetrics = DisplayMetrics()

        @Suppress("DEPRECATION")
        windowManager.defaultDisplay.getRealMetrics(displayMetrics)

        return "${displayMetrics.widthPixels}x${displayMetrics.heightPixels}"
    }

    private fun getTimezone(): String {
        return TimeZone.getDefault().id
    }

    private fun getLanguageCode(): String {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            context.resources.configuration.locales[0].language
        } else {
            @Suppress("DEPRECATION")
            context.resources.configuration.locale.language
        }
    }

    private fun isPrimaryDevice(): Boolean {
        val prefs = context.getSharedPreferences("device_info", Context.MODE_PRIVATE)
        val key = "is_primary_device"

        if (!prefs.contains(key)) {
            prefs.edit().putBoolean(key, true).apply()
            return true
        }

        return prefs.getBoolean(key, false)
    }

    private fun getScreenSizeInches(displayMetrics: DisplayMetrics): Double {
        val widthInches = displayMetrics.widthPixels / displayMetrics.xdpi
        val heightInches = displayMetrics.heightPixels / displayMetrics.ydpi
        return sqrt((widthInches * widthInches + heightInches * heightInches).toDouble())
    }
}