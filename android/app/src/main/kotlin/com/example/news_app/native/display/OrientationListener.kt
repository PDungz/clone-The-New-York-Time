import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.res.Configuration
import io.flutter.plugin.common.EventChannel

class OrientationListener(private val context: Context) : EventChannel.StreamHandler {
    private var eventSink: EventChannel.EventSink? = null
    private var orientationReceiver: BroadcastReceiver? = null
    
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        startListening()
    }
    
    override fun onCancel(arguments: Any?) {
        stopListening()
        eventSink = null
    }
    
    private fun startListening() {
        orientationReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                val orientation = when (context?.resources?.configuration?.orientation) {
                    Configuration.ORIENTATION_PORTRAIT -> "portrait"
                    Configuration.ORIENTATION_LANDSCAPE -> "landscape"
                    else -> "portrait"
                }
                eventSink?.success(orientation)
            }
        }
        
        val filter = IntentFilter(Intent.ACTION_CONFIGURATION_CHANGED)
        context.registerReceiver(orientationReceiver, filter)
    }
    
    private fun stopListening() {
        orientationReceiver?.let {
            try {
                context.unregisterReceiver(it)
            } catch (e: Exception) {
                // Receiver already unregistered
            }
            orientationReceiver = null
        }
    }
    
    fun destroy() {
        stopListening()
    }
}