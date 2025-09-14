package com.nytimes.news_app.native

import android.content.Context
import com.nytimes.news_app.native.device.DeviceNativeHandler
import io.flutter.embedding.engine.FlutterEngine
import com.nytimes.news_app.native.display.DisplayNativeHandler

object NativeChannelRegistry {
    private val handlers = mutableListOf<BaseNativeHandler>()

    fun setup(flutterEngine: FlutterEngine, context: Context) {
        // Register display handler
        registerHandler(DisplayNativeHandler(flutterEngine, context))

        // Register device handler
        registerHandler(DeviceNativeHandler(flutterEngine, context))

        handlers.forEach { it.initialize() }
        println("✅ Android: Native Channel Registry initialized with ${handlers.size} handlers")
    }

    private fun registerHandler(handler: BaseNativeHandler) {
        handlers.add(handler)
        println("📱 Android: Registered handler: ${handler.channelName}")
    }

    fun onDestroy() {
        println("🔥 Android: Destroying Native Channel Registry")
        handlers.forEach { it.onDestroy() }
        handlers.clear()
    }
}
