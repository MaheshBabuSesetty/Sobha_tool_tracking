/**
 * Static BroadcastReceiver for Newland Barcode Scanner results.
 * Action: nlscan.action.SCANNER_RESULT
 */
package com.sobha.powertracking.barcode

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class BarcodeScanReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "BarcodeScanReceiver"
        const val ACTION = "nlscan.action.SCANNER_RESULT"
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        Log.d(TAG, "onReceive - action: ${intent?.action}")

        if (intent?.action != ACTION) return

        val barcode = intent.getStringExtra("SCAN_BARCODE1")
            ?: intent.getStringExtra("SCAN_BARCODE2")

        if (!barcode.isNullOrEmpty()) {
            Log.d(TAG, "Barcode: $barcode")
        }
    }
}