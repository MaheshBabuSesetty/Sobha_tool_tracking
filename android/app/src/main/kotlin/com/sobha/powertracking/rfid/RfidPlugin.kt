/**
 * RFID Plugin for Flutter - Newland NLS-MT93-U UHF RFID Integration
 *
 * Production-grade implementation using official Newland UHF SDK.
 * Based on Newland Android PDA UHF Module Developer Handbook V1.0.3.
 *
 * Communication Channels:
 * - MethodChannel: Commands (initialize, startScan, stopScan, setPower, dispose)
 * - EventChannel: Tag data stream and connection state events
 */
package com.sobha.powertracking.rfid

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.nlscan.android.uhf.TagInfo
import com.nlscan.android.uhf.UHFCommonParams
import com.nlscan.android.uhf.UHFManager
import com.nlscan.android.uhf.UHFReader
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

/**
 * Flutter plugin for Newland UHF RFID functionality.
 *
 * Uses BroadcastReceiver to receive RFID tag data and asyncConnect
 * for device connection with fallback serial paths.
 */
class RfidPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    companion object {
        private const val TAG = "RfidPlugin"
        private const val METHOD_CHANNEL = "com.flexgate/rfid_method"
        private const val EVENT_CHANNEL = "com.flexgate/rfid_event"

        // Newland UHF broadcast actions
        private const val TAG_BROADCAST = "nlscan.intent.action.uhf.ACTION_RESULT"
        private const val STATE_BROADCAST = "com.nlscan.intent.action.ACTOIN_UHF_STATE_CHANGE"

        // Device configuration
        private const val DEVICE_MODEL = "UR90_V2.0"
        private val DEVICE_PATHS = listOf("/dev/ttyS0", "/dev/ttyS1", "/dev/ttyS4")

        // Power configuration (raw unit: 0.01 dBm, so 2700 = 27.00 dBm)
        private const val DEFAULT_POWER = 2700
        private const val MIN_POWER = 0
        private const val MAX_POWER = 3300
    }

    private var methodChannel: MethodChannel? = null
    private var eventChannel: EventChannel? = null
    private var eventSink: EventChannel.EventSink? = null
    private var context: Context? = null
    private var uhfManager: UHFManager? = null

    private var isReceiverRegistered = false
    private var isConnecting = false
    private var isAutoReconnectEnabled = true

    private val mainHandler = Handler(Looper.getMainLooper())

    /**
     * BroadcastReceiver for RFID tag scan results.
     * Receives tag data via nlscan.intent.action.uhf.ACTION_RESULT broadcast.
     */
    private val tagReceiver = object : BroadcastReceiver() {
        @Suppress("DEPRECATION")
        override fun onReceive(ctx: Context?, intent: Intent?) {
            if (intent?.action != TAG_BROADCAST) return

            try {
                val parcelables = intent.getParcelableArrayExtra("tag_info") ?: return
                val startTime = intent.getLongExtra("extra_start_reading_time", 0L)

                for (parcelable in parcelables) {
                    val tagInfo = parcelable as? TagInfo ?: continue
                    val epc = UHFReader.bytes_Hexstr(tagInfo.EpcId)

                    if (epc.isNullOrEmpty()) continue

                    mainHandler.post {
                        eventSink?.success(
                            mapOf(
                                "type" to "tag",
                                "epc" to epc,
                                "rssi" to tagInfo.RSSI,
                                "antennaId" to tagInfo.AntennaID.toInt(),
                                "readCount" to tagInfo.ReadCnt,
                                "timestamp" to System.currentTimeMillis(),
                                "startTime" to startTime
                            )
                        )
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error processing tag broadcast: ${e.message}", e)
            }
        }
    }

    /**
     * UHF state listener for connection management.
     */
    private val stateListener = object : UHFManager.AbsUHFStateListener() {
        override fun onConnectStateChange(connectState: Int) {
            Log.d(TAG, "UHF state changed: $connectState")

            when (connectState) {
                UHFManager.UHF_STATE_CONNECTED -> {
                    Log.d(TAG, "UHF module connected")
                    enableTriggers()
                    enableFeedback()
                    sendConnectionState("connected")
                }

                UHFManager.UHF_STATE_CONNECT_FAIL -> {
                    Log.w(TAG, "UHF connection failed")
                    sendConnectionState("failed")
                }

                UHFManager.UHF_STATE_DISCONNECTED -> {
                    Log.w(TAG, "UHF module disconnected")
                    sendConnectionState("disconnected")
                    scheduleReconnect()
                }

                UHFManager.UHF_STATE_CONNECTING -> {
                    Log.d(TAG, "UHF module connecting...")
                    sendConnectionState("connecting")
                }
            }
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        uhfManager = UHFManager.getInstance()

        methodChannel = MethodChannel(binding.binaryMessenger, METHOD_CHANNEL).apply {
            setMethodCallHandler(this@RfidPlugin)
        }

        eventChannel = EventChannel(binding.binaryMessenger, EVENT_CHANNEL).apply {
            setStreamHandler(this@RfidPlugin)
        }

        Log.d(TAG, "RfidPlugin attached to engine")
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        isAutoReconnectEnabled = false
        stopInventorySafely()
        unregisterTagReceiver()
        disconnectSafely()

        methodChannel?.setMethodCallHandler(null)
        methodChannel = null

        eventChannel?.setStreamHandler(null)
        eventChannel = null

        context = null

        Log.d(TAG, "RfidPlugin detached from engine")
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initialize" -> {
                isAutoReconnectEnabled = true
                connectWithFallback()
                result.success(true)
            }

            "startScan" -> {
                registerTagReceiver()
                val state = uhfManager?.startTagInventory()
                val success = state == UHFReader.READER_STATE.OK_ERR
                if (!success) {
                    Log.w(TAG, "startTagInventory returned: $state")
                }
                result.success(success)
            }

            "stopScan" -> {
                uhfManager?.stopTagInventory()
                unregisterTagReceiver()
                result.success(true)
            }

            "setPower" -> {
                val power = call.argument<Int>("power") ?: DEFAULT_POWER
                setAntennaPower(power)
                result.success(true)
            }

            "getPower" -> {
                result.success(getCurrentPower())
            }

            "setSound" -> {
                val enabled = call.argument<Boolean>("enabled") ?: true
                uhfManager?.setPromptSoundEnable(enabled)
                result.success(true)
            }

            "setVibration" -> {
                val enabled = call.argument<Boolean>("enabled") ?: true
                uhfManager?.setPromptVibrateEnable(enabled)
                result.success(true)
            }

            "dispose" -> {
                isAutoReconnectEnabled = false
                stopInventorySafely()
                unregisterTagReceiver()
                disconnectSafely()
                result.success(true)
            }

            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        registerTagReceiver()
        Log.d(TAG, "Event channel listener registered")
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
        unregisterTagReceiver()
        Log.d(TAG, "Event channel listener unregistered")
    }

    /**
     * Attempts connection using fallback device paths.
     */
    private fun connectWithFallback() {
        if (isConnecting) {
            Log.d(TAG, "Connection already in progress")
            return
        }

        isConnecting = true
        sendConnectionState("connecting")

        Thread {
            var connected = false

            for (path in DEVICE_PATHS) {
                Log.d(TAG, "Attempting connection on $path")
                if (tryConnect(path)) {
                    connected = true
                    break
                }
            }

            isConnecting = false

            if (!connected) {
                Log.e(TAG, "Failed to connect on all serial ports")
                mainHandler.post {
                    eventSink?.error(
                        "CONNECT_FAIL",
                        "UHF module not found on any serial port",
                        DEVICE_PATHS.joinToString(", ")
                    )
                }
            }
        }.start()
    }

    /**
     * Attempts connection on a specific device path.
     */
    private fun tryConnect(path: String): Boolean {
        val lock = Object()
        var connected = false

        val localListener = object : UHFManager.AbsUHFStateListener() {
            override fun onConnectStateChange(connectState: Int) {
                Log.d(TAG, "Connection state for $path: $connectState")

                when (connectState) {
                    UHFManager.UHF_STATE_CONNECTED -> {
                        connected = true
                        synchronized(lock) { lock.notifyAll() }
                    }

                    UHFManager.UHF_STATE_CONNECT_FAIL,
                    UHFManager.UHF_STATE_DISCONNECTED -> {
                        synchronized(lock) { lock.notifyAll() }
                    }
                }

                // Forward to main state listener
                stateListener.onConnectStateChange(connectState)
            }
        }

        try {
            val result = uhfManager?.asyncConnect(
                path,
                UHFManager.PLUGIN_TYPE_SERIEL,
                DEVICE_MODEL,
                localListener
            )

            if (result == UHFReader.READER_STATE.OK_ERR) {
                synchronized(lock) {
                    lock.wait(10000) // 10 second timeout
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Connection error on $path: ${e.message}", e)
        }

        return uhfManager?.isConnect ?: false
    }

    /**
     * Enables all physical trigger buttons.
     */
    private fun enableTriggers() {
        try {
            uhfManager?.setTrigger(UHFCommonParams.TRIGGER_MODE.TRIGGER_MODE_MAIN, true)
            uhfManager?.setTrigger(UHFCommonParams.TRIGGER_MODE.TRIGGER_MODE_LEFT, true)
            uhfManager?.setTrigger(UHFCommonParams.TRIGGER_MODE.TRIGGER_MODE_RIGHT, true)
            uhfManager?.setTrigger(UHFCommonParams.TRIGGER_MODE.TRIGGER_MODE_BACK, true)
            Log.d(TAG, "All triggers enabled")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to enable triggers: ${e.message}")
        }
    }

    /**
     * Enables sound and vibration feedback.
     */
    private fun enableFeedback() {
        try {
            uhfManager?.setPromptSoundEnable(true)
            uhfManager?.setPromptVibrateEnable(true)
            Log.d(TAG, "Sound and vibration enabled")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to enable feedback: ${e.message}")
        }
    }

    /**
     * Sends connection state event to Flutter.
     */
    private fun sendConnectionState(state: String) {
        mainHandler.post {
            eventSink?.success(
                mapOf(
                    "type" to "connection_state",
                    "state" to state
                )
            )
        }
    }

    /**
     * Schedules auto-reconnect after disconnection.
     */
    private fun scheduleReconnect() {
        if (!isAutoReconnectEnabled) return

        mainHandler.postDelayed({
            if (isAutoReconnectEnabled && uhfManager?.isConnect != true) {
                Log.d(TAG, "Auto-reconnecting...")
                connectWithFallback()
            }
        }, 2000)
    }

    /**
     * Registers the tag broadcast receiver.
     */
    private fun registerTagReceiver() {
        if (isReceiverRegistered) {
            Log.d(TAG, "Tag receiver already registered")
            return
        }

        val filter = IntentFilter(TAG_BROADCAST)

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                context?.registerReceiver(tagReceiver, filter, Context.RECEIVER_EXPORTED)
            } else {
                context?.registerReceiver(tagReceiver, filter)
            }
            isReceiverRegistered = true
            Log.d(TAG, "Tag receiver registered for: $TAG_BROADCAST")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to register tag receiver: ${e.message}")
        }
    }

    /**
     * Unregisters the tag broadcast receiver.
     */
    private fun unregisterTagReceiver() {
        if (!isReceiverRegistered) return

        try {
            context?.unregisterReceiver(tagReceiver)
            isReceiverRegistered = false
            Log.d(TAG, "Tag receiver unregistered")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to unregister tag receiver: ${e.message}")
        }
    }

    /**
     * Sets antenna power level.
     *
     * @param power Raw power value (0-3300, unit: 0.01 dBm)
     */
    private fun setAntennaPower(power: Int) {
        val clampedPower = power.coerceIn(MIN_POWER, MAX_POWER)
        val writePower = (clampedPower - 700).coerceAtLeast(0)

        try {
            val jsonArray = JSONArray()
            val jsonObject = JSONObject().apply {
                put("antid", 1)
                put("readPower", clampedPower)
                put("writePower", writePower)
            }
            jsonArray.put(jsonObject)

            uhfManager?.setParam("RF_ANTPOWER", "PARAM_RF_ANTPOWER", jsonArray.toString())
            Log.d(TAG, "Power set to $clampedPower (${clampedPower / 100.0} dBm)")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to set power: ${e.message}")
        }
    }

    /**
     * Gets current antenna power level.
     */
    private fun getCurrentPower(): Int {
        return try {
            val value = uhfManager?.getParam("RF_ANTPOWER", "PARAM_RF_ANTPOWER", null)
            if (value.isNullOrEmpty()) {
                DEFAULT_POWER
            } else {
                JSONArray(value).optJSONObject(0)?.optInt("readPower") ?: DEFAULT_POWER
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to get power: ${e.message}")
            DEFAULT_POWER
        }
    }

    /**
     * Safely stops inventory without throwing.
     */
    private fun stopInventorySafely() {
        try {
            uhfManager?.stopTagInventory()
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping inventory: ${e.message}")
        }
    }

    /**
     * Safely disconnects without throwing.
     */
    private fun disconnectSafely() {
        try {
            uhfManager?.disconnect()
        } catch (e: Exception) {
            Log.e(TAG, "Error disconnecting: ${e.message}")
        }
    }
}