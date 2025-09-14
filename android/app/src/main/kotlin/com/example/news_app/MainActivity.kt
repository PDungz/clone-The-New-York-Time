package com.nytimes.news_app

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import com.nytimes.news_app.native.NativeChannelRegistry

class MainActivity: FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        println("✅ MainActivity: Using FlutterFragmentActivity")  // Debug log
        NativeChannelRegistry.setup(flutterEngine, this)
    }

    override fun onDestroy() {
        super.onDestroy()
        NativeChannelRegistry.onDestroy()
    }
}