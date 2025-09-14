import android.content.Context
import android.database.ContentObserver
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import io.flutter.plugin.common.EventChannel

class BrightnessListener(private val context: Context) : EventChannel.StreamHandler {
    private var eventSink: EventChannel.EventSink? = null
    private var brightnessObserver: ContentObserver? = null
    private val handler = Handler(Looper.getMainLooper())
    
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        startListening()
        
        // Send current brightness immediately
        try {
            val brightness = Settings.System.getInt(
                context.contentResolver,
                Settings.System.SCREEN_BRIGHTNESS
            ) / 255.0
            events?.success(brightness)
        } catch (e: Exception) {
            // Ignore
        }
    }
    
    override fun onCancel(arguments: Any?) {
        stopListening()
        eventSink = null
    }
    
    private fun startListening() {
        brightnessObserver = object : ContentObserver(handler) {
            override fun onChange(selfChange: Boolean, uri: Uri?) {
                super.onChange(selfChange, uri)
                try {
                    val brightness = Settings.System.getInt(
                        context.contentResolver,
                        Settings.System.SCREEN_BRIGHTNESS
                    ) / 255.0
                    eventSink?.success(brightness)
                } catch (e: Exception) {
                    // Ignore errors
                }
            }
        }
        
        try {
            context.contentResolver.registerContentObserver(
                Settings.System.getUriFor(Settings.System.SCREEN_BRIGHTNESS),
                false,
                brightnessObserver!!
            )
        } catch (e: Exception) {
            // Permission might not be available
        }
    }
    
    private fun stopListening() {
        brightnessObserver?.let {
            try {
                context.contentResolver.unregisterContentObserver(it)
            } catch (e: Exception) {
                // Observer already unregistered
            }
            brightnessObserver = null
        }
    }
    
    fun destroy() {
        stopListening()
    }
}
