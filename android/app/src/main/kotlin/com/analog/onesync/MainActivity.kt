package com.analog.onesync

import android.content.Intent
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    private val CHANNEL = "onesync/battery_optimization"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->

                if (call.method == "isIgnoringBatteryOptimizations") {

                    val pm = getSystemService(POWER_SERVICE) as PowerManager
                    val packageName = packageName

                    val isIgnoring =
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            pm.isIgnoringBatteryOptimizations(packageName)
                        } else {
                            true
                        }

                    result.success(isIgnoring)

                } else if (call.method == "requestDisableBatteryOptimization") {

                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {

                        val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
                        intent.data = android.net.Uri.parse("package:$packageName")
                        startActivity(intent)
                    }

                    result.success(null)
                }
            }
    }
}