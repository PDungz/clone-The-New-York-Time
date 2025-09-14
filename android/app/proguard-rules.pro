# Keep native handlers
-keep class com.nytimes.news_app.native.** { *; }
-keep class com.nytimes.news_app.utils.** { *; }

# Keep Flutter method channel classes
-keep class io.flutter.plugin.common.** { *; }