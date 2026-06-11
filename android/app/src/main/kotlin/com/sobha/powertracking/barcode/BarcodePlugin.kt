/**
 * BarcodePlugin - Native Android plugin for Newland NLS-MT93 barcode scanner integration.
 * Handles BroadcastReceiver registration and EventChannel communication with Flutter.
 */
package com.sobha.powertracking.barcode

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class BarcodePlugin : FlutterPlugin,
    MethodChannel.MethodCallHandler,
    EventChannel.StreamHandler {

    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var eventSink: EventChannel.EventSink? = null
    private var context: Context? = null
    private var isReceiverRegistered: Boolean = false

    companion object {
        private const val TAG = "BarcodePlugin"
        const val METHOD_CHANNEL = "com.flexgate/barcode_method"
        const val EVENT_CHANNEL = "com.flexgate/barcode_event"

        // Newland NLS-MT93 broadcast actions
        const val ACTION_SCAN_RESULT = "nlscan.action.SCANNER_RESULT"
        const val ACTION_SCAN_TRIG = "nlscan.action.SCANNER_TRIG"
        const val ACTION_STOP_SCAN = "nlscan.action.STOP_SCAN"

        // Broadcast extras
        const val EXTRA_BARCODE_1 = "SCAN_BARCODE1"
        const val EXTRA_BARCODE_2 = "SCAN_BARCODE2"
        const val EXTRA_BARCODE_TYPE = "SCAN_BARCODE_TYPE"
    }

    private val mainHandler = Handler(Looper.getMainLooper())

    private val scanReceiver = object : BroadcastReceiver() {
        override fun onReceive(ctx: Context?, intent: Intent?) {
            Log.d(TAG, "onReceive fired: ${intent?.action}")

            if (intent?.action != ACTION_SCAN_RESULT) return

            val barcode1 = intent.getStringExtra(EXTRA_BARCODE_1) ?: ""
            val barcode2 = intent.getStringExtra(EXTRA_BARCODE_2) ?: ""
            val type = intent.getStringExtra(EXTRA_BARCODE_TYPE) ?: "UNKNOWN"
            val value = barcode1.ifEmpty { barcode2 }

            Log.d(TAG, "Scanned: $value [$type]")

            if (value.isNotEmpty()) {
                // CRITICAL: EventSink.success() MUST be called on main thread
                mainHandler.post {
                    eventSink?.success(mapOf("value" to value, "type" to type))
                    Log.d(TAG, "Sent to Flutter: $value [$type]")
                }
            }
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        methodChannel = MethodChannel(binding.binaryMessenger, METHOD_CHANNEL)
        methodChannel.setMethodCallHandler(this)
        eventChannel = EventChannel(binding.binaryMessenger, EVENT_CHANNEL)
        eventChannel.setStreamHandler(this)
        Log.d(TAG, "BarcodePlugin attached to engine")
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        unregisterScanReceiver()
        context = null
        Log.d(TAG, "BarcodePlugin detached from engine")
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startScan" -> {
                Log.d(TAG, "startScan called")
                registerScanReceiver()
                // Send broadcast to trigger scanner
                context?.sendBroadcast(Intent(ACTION_SCAN_TRIG))
                Log.d(TAG, "Sent SCANNER_TRIG broadcast")
                result.success(true)
            }
            "stopScan" -> {
                Log.d(TAG, "stopScan called")
                // Send broadcast to stop scanner
                context?.sendBroadcast(Intent(ACTION_STOP_SCAN))
                Log.d(TAG, "Sent STOP_SCAN broadcast")
                unregisterScanReceiver()
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) {
        eventSink = sink
        registerScanReceiver()
        Log.d(TAG, "EventChannel onListen - sink ready")
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
        unregisterScanReceiver()
        Log.d(TAG, "EventChannel onCancel")
    }

    private fun registerScanReceiver() {
        if (isReceiverRegistered) {
            Log.d(TAG, "Receiver already registered - skipping")
            return
        }

        val filter = IntentFilter(ACTION_SCAN_RESULT)

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                // Android 13+ (API 33) requires explicit RECEIVER_EXPORTED flag
                context?.registerReceiver(scanReceiver, filter, Context.RECEIVER_EXPORTED)
            } else {
                context?.registerReceiver(scanReceiver, filter)
            }
            isReceiverRegistered = true
            Log.d(TAG, "Receiver registered for: $ACTION_SCAN_RESULT")
        } catch (e: Exception) {
            Log.e(TAG, "registerReceiver failed: ${e.message}")
        }
    }

    private fun unregisterScanReceiver() {
        if (!isReceiverRegistered) return

        try {
            context?.unregisterReceiver(scanReceiver)
            isReceiverRegistered = false
            Log.d(TAG, "Receiver unregistered")
        } catch (e: Exception) {
            Log.e(TAG, "unregisterReceiver failed: ${e.message}")
        }
    }
}