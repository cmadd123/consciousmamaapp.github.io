package com.momrise.app

import android.content.Intent
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "com.momrise.app/sharing"
    private var sharedData: Map<String, String>? = null
    private var methodChannel: MethodChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d("MainActivity", "onCreate called")
        handleIncomingIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        Log.d("MainActivity", "onNewIntent called")
        handleIncomingIntent(intent)
    }

    private fun handleIncomingIntent(intent: Intent?) {
        Log.d("MainActivity", "handleIncomingIntent: action=${intent?.action}, type=${intent?.type}")
        when (intent?.action) {
            Intent.ACTION_SEND -> {
                if (intent.type == "text/plain") {
                    val sharedText = intent.getStringExtra(Intent.EXTRA_TEXT)
                    Log.d("MainActivity", "Received shared text: $sharedText")
                    if (sharedText != null) {
                        sharedData = mapOf(
                            "type" to "text",
                            "value" to sharedText
                        )
                        // CRITICAL: Notify Flutter immediately when app is already running
                        methodChannel?.invokeMethod("onSharedData", sharedData)
                    }
                }
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "getSharedData" -> {
                    Log.d("MainActivity", "Flutter requested sharedData: $sharedData")
                    result.success(sharedData)
                }
                "clearSharedData" -> {
                    Log.d("MainActivity", "Clearing sharedData")
                    sharedData = null
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
