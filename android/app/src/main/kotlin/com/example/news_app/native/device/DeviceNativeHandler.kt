package com.nytimes.news_app.native.device

import android.content.Context
import com.nytimes.news_app.native.BaseNativeHandler
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import kotlinx.coroutines.*

class DeviceNativeHandler(
    flutterEngine: FlutterEngine,
    context: Context
) : BaseNativeHandler(flutterEngine, context) {

    override val channelName: String = "device_service"
    override val eventChannels: Map<String, String> = mapOf()

    private lateinit var provider: DeviceInfoProvider

    override fun initialize() {
        super.initialize()
        provider = DeviceInfoProvider(context)
    }

    override fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getDeviceInfo" -> {
                try {
                    // Async method with location
                    provider.getDeviceInfo { info ->
                        GlobalScope.launch(Dispatchers.Main) {
                            result.success(info)
                        }
                    }
                } catch (e: Exception) {
                    result.error("GET_DEVICE_INFO_ERROR", "Failed to get device info: ${e.message}", null)
                }
            }

            "getDeviceInfoSync" -> {
                try {
                    // Sync method without full location
                    val info = provider.getDeviceInfoSync()
                    result.success(info)
                } catch (e: Exception) {
                    result.error("GET_DEVICE_INFO_SYNC_ERROR", "Failed to get device info sync: ${e.message}", null)
                }
            }

            "getSystemInfo" -> {
                try {
                    val info = provider.getSystemInfo()
                    result.success(info)
                } catch (e: Exception) {
                    result.error("GET_SYSTEM_INFO_ERROR", "Failed to get system info: ${e.message}", null)
                }
            }

            "getDeviceIdentifier" -> {
                try {
                    val identifier = provider.getDeviceIdentifier()
                    result.success(identifier)
                } catch (e: Exception) {
                    result.error("GET_DEVICE_ID_ERROR", "Failed to get device identifier: ${e.message}", null)
                }
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    override fun getStreamHandler(eventName: String): EventChannel.StreamHandler? {
        return null // Không cần stream handlers cho bây giờ
    }
}