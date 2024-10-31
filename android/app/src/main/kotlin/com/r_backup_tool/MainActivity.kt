package com.r_backup_tool

import android.content.pm.PackageManager
import android.os.Build
import android.os.Environment
import androidx.annotation.RequiresApi
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.random.Random

class MainActivity : FlutterActivity() {

    private val callbackMap = hashMapOf<Int, MethodChannel.Result>();

    @RequiresApi(Build.VERSION_CODES.M)
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "rbackup"
        )
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "checkStoragePermission" -> {
                    println("testpermission checkStoragePermission ${ContextCompat.checkSelfPermission(
                        this,
                        android.Manifest.permission.WRITE_EXTERNAL_STORAGE
                    )}   ${ContextCompat.checkSelfPermission(
                        this,
                        android.Manifest.permission.READ_EXTERNAL_STORAGE
                    )}   ${ContextCompat.checkSelfPermission(
                        this,
                        android.Manifest.permission.MANAGE_EXTERNAL_STORAGE
                    )}")

                    result.success(checkStoragePermission())
                }

                "requestStoragePermission" -> {
                    if (checkStoragePermission()) {
                        result.success(true)
                    } else {
                        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
                            val code = Random.nextInt(until = 900)
                            callbackMap[code] = result;
                            requestPermissions(
                                arrayOf(
                                    android.Manifest.permission.WRITE_EXTERNAL_STORAGE,
                                    android.Manifest.permission.READ_EXTERNAL_STORAGE,
                                ), code
                            )
                        } else {
                            val code = Random.nextInt(until = 900)
                            callbackMap[code] = result;
                            requestPermissions(
                                arrayOf(
                                    android.Manifest.permission.WRITE_EXTERNAL_STORAGE,
                                    android.Manifest.permission.READ_EXTERNAL_STORAGE,
                                    android.Manifest.permission.MANAGE_EXTERNAL_STORAGE
                                ), code
                            )
                        }
                    }
                }

                "getDownloadDirectory" -> {
                    result.success(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS).absolutePath)
                }

                "getDocumentDirectory" -> {
                    result.success(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS).absolutePath)
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
        println("testpermission permission $requestCode ${permissions.contentToString()} ${grantResults.contentToString()}")
        callbackMap.remove(requestCode)
            ?.success(grantResults.all { it == PackageManager.PERMISSION_GRANTED })
    }


    private fun checkStoragePermission() =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
            (if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU)
                ContextCompat.checkSelfPermission(
                    this,
                    android.Manifest.permission.WRITE_EXTERNAL_STORAGE
                ) == PackageManager.PERMISSION_GRANTED
            else
                ContextCompat.checkSelfPermission(
                    this,
                    android.Manifest.permission.MANAGE_EXTERNAL_STORAGE
                ) == PackageManager.PERMISSION_GRANTED)
        else
            true


}
