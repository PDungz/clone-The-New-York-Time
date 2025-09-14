package com.nytimes.news_app.native.display

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.res.Configuration
import android.database.ContentObserver
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.view.WindowManager
import androidx.annotation.RequiresApi
import io.flutter.plugin.common.EventChannel

class DisplayInfoProvider(private val context: Context) {

    @RequiresApi(Build.VERSION_CODES.N)
    fun getDisplayInfo(): Map<String, Any> {
        val displayMetrics = context.resources.displayMetrics
        val configuration = context.resources.configuration

        return mapOf(
            "themeMode" to getThemeMode(),
            "isDarkMode" to isDarkMode(),
            "screenBrightness" to getScreenBrightness(),
            "fontSize" to getFontSize(),
            "orientation" to getOrientationString(),
            "screenWidth" to displayMetrics.widthPixels.toDouble(),
            "screenHeight" to displayMetrics.heightPixels.toDouble(),
            "screenInches" to 6.1,
            "devicePixelRatio" to displayMetrics.density.toDouble(),
            "statusBarHeight" to getStatusBarHeight().toDouble(),
            "navigationBarHeight" to getNavigationBarHeight().toDouble(),
            "isLargeTextEnabled" to (configuration.fontScale > 1.15f),
            "isReduceMotionEnabled" to false,
            "languageCode" to configuration.locales[0].language,
            "screenDensity" to displayMetrics.densityDpi.toDouble(),
            "textScaleFactor" to configuration.fontScale.toDouble(),
            "fontFamily" to "Roboto",
            "isBoldTextEnabled" to false,
            "isHighContrastEnabled" to false,
            "isInvertColorsEnabled" to false,
            "colorScheme" to "normal",
            "animationDurationScale" to 1.0,
            "transitionAnimationScale" to 1.0,
            "isRTL" to (configuration.layoutDirection == Configuration.SCREENLAYOUT_LAYOUTDIR_RTL)
        )
    }

    fun getRefreshRate(): Float {
        return try {
            (context.getSystemService(Context.WINDOW_SERVICE) as WindowManager).defaultDisplay.refreshRate
        } catch (e: Exception) {
            60.0f
        }
    }

    fun setBrightness(brightness: Double): Boolean {
        return try {
            val value = (brightness * 255).toInt().coerceIn(0, 255)
            Settings.System.putInt(context.contentResolver, Settings.System.SCREEN_BRIGHTNESS, value)
            true
        } catch (e: Exception) {
            false
        }
    }

    fun isPortrait(): Boolean = getOrientationString() == "portrait"
    fun isLandscape(): Boolean = getOrientationString() == "landscape"
    fun isDarkMode(): Boolean = (context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK) == Configuration.UI_MODE_NIGHT_YES

    fun getScreenSize(): Map<String, Double> {
        val dm = context.resources.displayMetrics
        return mapOf("width" to dm.widthPixels.toDouble(), "height" to dm.heightPixels.toDouble())
    }

    fun getScreenInches(): Double = 6.1 // Simplified

    private fun getThemeMode(): String {
        return when (context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK) {
            Configuration.UI_MODE_NIGHT_YES -> "dark"
            Configuration.UI_MODE_NIGHT_NO -> "light"
            else -> "auto"
        }
    }

    private fun getScreenBrightness(): Double {
        return try {
            Settings.System.getInt(context.contentResolver, Settings.System.SCREEN_BRIGHTNESS) / 255.0
        } catch (e: Exception) {
            1.0
        }
    }

    private fun getFontSize(): Double = 16.0 * context.resources.configuration.fontScale

    private fun getOrientationString(): String {
        return when (context.resources.configuration.orientation) {
            Configuration.ORIENTATION_PORTRAIT -> "portrait"
            Configuration.ORIENTATION_LANDSCAPE -> "landscape"
            else -> "portrait"
        }
    }

    private fun getStatusBarHeight(): Int {
        val resourceId = context.resources.getIdentifier("status_bar_height", "dimen", "android")
        return if (resourceId > 0) context.resources.getDimensionPixelSize(resourceId) else 0
    }

    private fun getNavigationBarHeight(): Int {
        val resourceId = context.resources.getIdentifier("navigation_bar_height", "dimen", "android")
        return if (resourceId > 0) context.resources.getDimensionPixelSize(resourceId) else 0
    }
}