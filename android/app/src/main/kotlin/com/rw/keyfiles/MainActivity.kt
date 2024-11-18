package com.rw.keyfiles

import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.provider.Settings
import androidx.annotation.RequiresApi
import androidx.core.content.ContextCompat
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.random.Random


class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            installSplashScreen()
        } else {
            setTheme(R.style.NormalTheme)
        }
        super.onCreate(savedInstanceState)
    }

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
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                        println(
                            "testpermission checkStoragePermission ${
                                ContextCompat.checkSelfPermission(
                                    this,
                                    android.Manifest.permission.WRITE_EXTERNAL_STORAGE
                                )
                            }   ${
                                ContextCompat.checkSelfPermission(
                                    this,
                                    android.Manifest.permission.READ_EXTERNAL_STORAGE
                                )
                            }   ${Environment.isExternalStorageManager()}"
                        )
                    }

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
                            val intent =
                                Intent(Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION)
                            intent.setData(Uri.parse("package:$packageName"))
                            if (intent.resolveActivity(
                                    packageManager
                                ) != null
                            ) {
                                callbackMap[code] = result;
                                startActivityForResult(intent, code)
                            } else {
                                val intent2 =
                                    Intent(Settings.ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION)
                                if (intent2.resolveActivity(
                                        packageManager
                                    ) != null
                                ) {
                                    callbackMap[code] = result;
                                    startActivityForResult(intent2, code)
                                } else {
                                    result.success(false)
                                }
                            }
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

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            println("testpermission permission 12 $requestCode ${Environment.isExternalStorageManager()}")

            callbackMap.remove(requestCode)
                ?.success(Environment.isExternalStorageManager())
        }

    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        println("testpermission permission $requestCode ${permissions.contentToString()} ${grantResults.contentToString()}")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            println("testpermission permission 12 $requestCode ${Environment.isExternalStorageManager()}")
        }
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
                Environment.isExternalStorageManager())
        else
            true


}
