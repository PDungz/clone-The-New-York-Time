package com.nytimes.news_app.native.display

import BrightnessListener
import OrientationListener
import android.content.Context
import android.os.Build
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.EventChannel
import com.nytimes.news_app.native.BaseNativeHandler

class DisplayNativeHandler(flutterEngine: FlutterEngine, context: Context) : BaseNativeHandler(flutterEngine, context) {

    override val channelName = "display_service"
    override val eventChannels = mapOf(
        "orientation" to "display_service/orientation",
        "brightness" to "display_service/brightness"
    )

    private val provider = DisplayInfoProvider(context)
    private var orientationListener: OrientationListener? = null
    private var brightnessListener: BrightnessListener? = null

    @RequiresApi(Build.VERSION_CODES.N)
    override fun handleMethodCall(call: MethodCall, result: Result) {
        try {
            when (call.method) {
                "getDisplayInfo" -> result.success(provider.getDisplayInfo())
                "getRefreshRate" -> result.success(provider.getRefreshRate().toDouble())
                "setBrightness" -> {
                    val brightness = call.arguments as? Double ?: 1.0
                    result.success(provider.setBrightness(brightness))
                }
                "isPortrait" -> result.success(provider.isPortrait())
                "isLandscape" -> result.success(provider.isLandscape())
                "isDarkMode" -> result.success(provider.isDarkMode())
                "getScreenSize" -> result.success(provider.getScreenSize())
                "getScreenInches" -> result.success(provider.getScreenInches())
                else -> result.notImplemented()
            }
        } catch (e: Exception) {
            result.error("NATIVE_ERROR", e.message, null)
        }
    }

    override fun getStreamHandler(eventName: String): EventChannel.StreamHandler? {
        return when (eventName) {
            "orientation" -> {
                orientationListener = OrientationListener(context)
                orientationListener
            }
            "brightness" -> {
                brightnessListener = BrightnessListener(context)
                brightnessListener
            }
            else -> null
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        orientationListener?.destroy()
        brightnessListener?.destroy()
        orientationListener = null
        brightnessListener = null
    }
}