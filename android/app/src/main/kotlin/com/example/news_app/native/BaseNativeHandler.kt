package com.nytimes.news_app.native

import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result

abstract class BaseNativeHandler(
    protected val flutterEngine: FlutterEngine,
    protected val context: Context
) {
    abstract val channelName: String
    abstract val eventChannels: Map<String, String>

    protected lateinit var methodChannel: MethodChannel
    protected val eventChannelMap = mutableMapOf<String, EventChannel>()

    open fun initialize() {
        setupMethodChannel()
        setupEventChannels()
        println("✅ Android: Initialized handler: $channelName")
    }

    private fun setupMethodChannel() {
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        methodChannel.setMethodCallHandler { call, result ->
            println("📞 Android: Method call: ${call.method} on $channelName")
            handleMethodCall(call, result)
        }
    }

    private fun setupEventChannels() {
        eventChannels.forEach { (name, channel) ->
            val eventChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            eventChannelMap[name] = eventChannel
            eventChannel.setStreamHandler(getStreamHandler(name))
            println("🔄 Android: Setup event channel: $channel")
        }
    }

    abstract fun handleMethodCall(call: MethodCall, result: Result)
    open fun getStreamHandler(eventName: String): EventChannel.StreamHandler? = null
    open fun onDestroy() {
        eventChannelMap.clear()
        println("💥 Android: Destroyed handler: $channelName")
    }
}