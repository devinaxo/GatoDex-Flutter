package com.devinaxo.gatodex

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.devinaxo.gatodex/file_intent"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialFileIntent" -> {
                    val path = handleIntent(intent)
                    result.success(path)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val path = handleIntent(intent)
        if (path != null) {
            flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                MethodChannel(messenger, CHANNEL).invokeMethod("onFileReceived", path)
            }
        }
    }

    private fun handleIntent(intent: Intent?): String? {
        if (intent == null) return null

        val uri: Uri? = when (intent.action) {
            Intent.ACTION_VIEW -> intent.data
            Intent.ACTION_SEND -> intent.getParcelableExtra(Intent.EXTRA_STREAM)
            else -> null
        }

        if (uri == null) return null

        return try {
            // Copy the content to a temp file since we might not have direct access
            val inputStream = contentResolver.openInputStream(uri)
            if (inputStream != null) {
                val fileName = "imported_backup_${System.currentTimeMillis()}.json"
                val tempFile = File(cacheDir, fileName)
                FileOutputStream(tempFile).use { output ->
                    inputStream.copyTo(output)
                }
                inputStream.close()
                tempFile.absolutePath
            } else {
                null
            }
        } catch (e: Exception) {
            null
        }
    }
}
