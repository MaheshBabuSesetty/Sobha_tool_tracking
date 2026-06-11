package com.sobha.powertracking

import android.content.Context
import android.os.Build
import android.os.Bundle
import android.os.Debug
import android.provider.Settings
import android.view.WindowManager
import com.sobha.powertracking.barcode.BarcodePlugin
import com.sobha.powertracking.rfid.RfidPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.File
import java.io.InputStreamReader
import java.net.InetSocketAddress
import java.net.Socket

class MainActivity : FlutterActivity() {

    private val SECURITY_CHANNEL = "com.sobha.powertracking/security"
    private val SCREEN_CHANNEL = "com.sobha.powertracking/screen_protection"


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        flutterEngine.plugins.add(RfidPlugin())
        flutterEngine.plugins.add(BarcodePlugin())

        setupSecurityChannel(flutterEngine)
        setupScreenProtectionChannel(flutterEngine)
    }

    private fun setupSecurityChannel(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SECURITY_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {

                "isRootedOrJailbroken" -> result.success(isRooted())

                "isHookedOrInstrumented" -> result.success(isHookedOrInstrumented())

                "isDebuggerAttached" -> result.success(isDebuggerAttached())

                "isDeveloperMode" -> result.success(isDeveloperModeEnabled(this))

                "isEmulator" -> result.success(isEmulator())

                else -> result.notImplemented()
            }
        }
    }

    private fun setupScreenProtectionChannel(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SCREEN_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {

                "enableSecure" -> {
                    window.setFlags(
                        WindowManager.LayoutParams.FLAG_SECURE,
                        WindowManager.LayoutParams.FLAG_SECURE
                    )
                    result.success(true)
                }

                "disableSecure" -> {
                    window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    result.success(true)
                }

                else -> result.notImplemented()
            }
        }
    }

    // -----------------------------
    // Root detection (multi-signal)
    // -----------------------------
    private fun isRooted(): Boolean {
        // A) Known root artifacts (su/magisk)
        val paths = arrayOf(
            "/sbin/su",
            "/system/bin/su",
            "/system/xbin/su",
            "/system/app/Superuser.apk",
            "/system/bin/busybox",
            "/system/xbin/busybox",
            "/data/local/xbin/su",
            "/data/local/bin/su",
            "/su/bin/su",
            "/magisk/.core/bin/su",
            "/sbin/magisk",
            "/system/bin/magisk",
            "/system/xbin/magisk",
            "/data/adb/magisk",
            "/data/adb/modules",
            "/data/adb/service.d",
            "/data/adb/post-fs-data.d"
        )
        if (paths.any { File(it).exists() }) return true

        // B) Build tags
        val tags = Build.TAGS
        if (tags != null && tags.contains("test-keys")) return true

        // C) "which su" check
        if (canFindSuBinary()) return true

        // D) Dangerous system properties
        if (hasDangerousSystemProps()) return true

        return false
    }

    private fun canFindSuBinary(): Boolean {
        return try {
            val process = Runtime.getRuntime().exec(arrayOf("sh", "-c", "which su"))
            val reader = BufferedReader(InputStreamReader(process.inputStream))
            val line = reader.readLine()
            line != null && line.isNotBlank()
        } catch (_: Throwable) {
            false
        }
    }

    private fun hasDangerousSystemProps(): Boolean {
        return try {
            val process = Runtime.getRuntime().exec(arrayOf("sh", "-c", "getprop"))
            val output = process.inputStream.bufferedReader().readText()

            output.contains("[ro.debuggable]: [1]") ||
                    output.contains("[ro.secure]: [0]") ||
                    output.contains("[service.adb.root]: [1]")
        } catch (_: Throwable) {
            false
        }
    }

    // -----------------------------
    // Hooking detection (Frida/Xposed) - best effort
    // -----------------------------
    private fun isHookedOrInstrumented(): Boolean {
        // A) File traces
        val fridaPaths = arrayOf(
            "/data/local/tmp/frida-server",
            "/data/local/tmp/re.frida.server",
            "/sdcard/frida-server"
        )
        if (fridaPaths.any { File(it).exists() }) return true

        val xposedPaths = arrayOf(
            "/system/framework/XposedBridge.jar",
            "/system/lib/libxposed_art.so",
            "/system/lib64/libxposed_art.so",
            "/system/bin/app_process64_xposed",
            "/system/bin/app_process32_xposed"
        )
        if (xposedPaths.any { File(it).exists() }) return true

        // B) Frida ports (fast timeout)
        if (isLocalPortOpen(27042) || isLocalPortOpen(27043)) return true

        // C) Scan process maps for suspicious libs (best effort; may be restricted on newer Android)
        if (scanProcMapsForSuspiciousLibs()) return true

        return false
    }

    private fun isLocalPortOpen(port: Int): Boolean {
        return try {
            Socket().use { socket ->
                socket.connect(InetSocketAddress("127.0.0.1", port), 120)
                true
            }
        } catch (_: Throwable) {
            false
        }
    }

    private fun scanProcMapsForSuspiciousLibs(): Boolean {
        return try {
            val maps = File("/proc/self/maps")
            if (!maps.exists()) return false

            val text = maps.readText()
            val needles = listOf("frida", "xposed", "substrate", "magisk", "zygisk")
            needles.any { text.contains(it, ignoreCase = true) }
        } catch (_: Throwable) {
            false
        }
    }

    // -----------------------------
    // Debugger detection
    // -----------------------------
    private fun isDebuggerAttached(): Boolean {
        return Debug.isDebuggerConnected() || Debug.waitingForDebugger()
    }

    // -----------------------------
    // Developer mode detection
    // -----------------------------
    private fun isDeveloperModeEnabled(context: Context): Boolean {
        return try {
            Settings.Global.getInt(
                context.contentResolver,
                Settings.Global.DEVELOPMENT_SETTINGS_ENABLED,
                0
            ) == 1
        } catch (_: Throwable) {
            false
        }
    }

    // -----------------------------
    // Emulator detection
    // -----------------------------
    private fun isEmulator(): Boolean {
        val fingerprint = Build.FINGERPRINT.lowercase()
        val model = Build.MODEL.lowercase()
        val manufacturer = Build.MANUFACTURER.lowercase()
        val brand = Build.BRAND.lowercase()
        val device = Build.DEVICE.lowercase()
        val product = Build.PRODUCT.lowercase()

        return fingerprint.contains("generic") ||
                fingerprint.contains("emulator") ||
                fingerprint.contains("test-keys") ||
                model.contains("google_sdk") ||
                model.contains("emulator") ||
                model.contains("sdk_gphone") ||
                manufacturer.contains("genymotion") ||
                (brand.contains("generic") && device.contains("generic")) ||
                product.contains("sdk") ||
                product.contains("emulator") ||
                product.contains("simulator")
    }
}