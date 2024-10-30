package com.r_backup_tool

import android.content.pm.PackageManager
import android.os.Build
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.random.Random

class MainActivity : FlutterActivity() {

    private val callbackMap = hashMapOf<Int, MethodChannel.Result>();

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "rbackup"
        )
        channel.setMethodCallHandler { call, result ->
            if (call.method == "requestStoragePermission") {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
                        if (ContextCompat.checkSelfPermission(
                                this,
                                android.Manifest.permission.WRITE_EXTERNAL_STORAGE
                            ) == PackageManager.PERMISSION_GRANTED
                        ) {
                            result.success(true);
                            return@setMethodCallHandler
                        } else {
                            val code = Random.nextInt(until = 900)
                            callbackMap[code] = result;
                            requestPermissions(
                                arrayOf(
                                    android.Manifest.permission.WRITE_EXTERNAL_STORAGE,
                                    android.Manifest.permission.READ_EXTERNAL_STORAGE,
                                ), code
                            )
                        }
                    } else {
                        if (ContextCompat.checkSelfPermission(
                                this,
                                android.Manifest.permission.MANAGE_EXTERNAL_STORAGE
                            ) == PackageManager.PERMISSION_GRANTED
                        ) {
                            result.success(true);
                            return@setMethodCallHandler
                        } else {
                            val code = Random.nextInt(until = 900)
                            callbackMap[code] = result;
                            println("testpermission check $code")
                            requestPermissions(
                                arrayOf(
                                    android.Manifest.permission.MANAGE_EXTERNAL_STORAGE
                                ), code
                            )
                        }
                    }
                } else {
                    result.success(true);
                }
            }
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        println("testpermission callback $requestCode")
        callbackMap.remove(requestCode)?.success(true);
        println("testpermission permission $requestCode ${permissions.contentToString()} ${grantResults.contentToString()}")
    }
}
