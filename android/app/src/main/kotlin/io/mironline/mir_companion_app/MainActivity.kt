package io.mironline.mir_companion_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngine // Added this import

class MainActivity: FlutterActivity() {
    private val CHANNEL = "refresh_rate"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "setRefreshRate") {
                try {
                    val rate = call.argument<Double>("rate")?.toFloat() ?: 60f
                    window.attributes = window.attributes.apply {
                        preferredRefreshRate = rate
                    }
                    result.success(null)
                } catch (e: Exception) {
                    result.error("REFRESH_RATE_ERROR", "Failed to set refresh rate: ${e.message}", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}