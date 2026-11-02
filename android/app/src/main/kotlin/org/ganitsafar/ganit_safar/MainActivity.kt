package org.ganitsafar.ganit_safar

import android.app.Activity
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var pending: MethodChannel.Result? = null
    private var backup: String? = null
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "org.ganitsafar/backup")
            .setMethodCallHandler { call, result ->
                if (call.method != "saveBackup") { result.notImplemented(); return@setMethodCallHandler }
                if (pending != null) { result.error("busy", "A save dialog is already open", null); return@setMethodCallHandler }
                pending = result
                backup = call.argument<String>("json")
                try {
                    val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                        addCategory(Intent.CATEGORY_OPENABLE)
                        type = "application/json"
                        putExtra(Intent.EXTRA_TITLE, "ganit-safar-backup.json")
                    }
                    @Suppress("DEPRECATION")
                    startActivityForResult(intent, 601)
                } catch (e: Exception) { pending = null; backup = null; result.error("save", e.message, null) }
            }
    }
    @Deprecated("Activity result API retained for Flutter embedding compatibility")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != 601) return
        val result = pending ?: return
        try {
            val uri = data?.data
            if (resultCode != Activity.RESULT_OK || uri == null) { result.success(false) }
            else {
                val stream = contentResolver.openOutputStream(uri, "wt") ?: throw IllegalStateException("Cannot open document")
                stream.use { it.write((backup ?: "").toByteArray(Charsets.UTF_8)) }
                result.success(true)
            }
        } catch (e: Exception) { result.error("save", e.message, null) }
        finally { pending = null; backup = null }
    }
}
