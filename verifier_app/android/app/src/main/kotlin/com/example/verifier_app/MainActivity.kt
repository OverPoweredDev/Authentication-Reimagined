package com.example.verifier_app

import android.app.Activity
import android.content.Intent
import androidx.annotation.NonNull

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    var RESULT = true;
    private val CHANNEL = "faceRD"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "captureIntent") {
                invokeCaptureIntent()
            } else if (call.method == "lightingIntent") {
                invokeLightingIntent()
            } else if (call.method == "getResult") {
                result.success(RESULT)
            } else {
                result.notImplemented()
            }
        }
    }

    fun createPidOptions(txnId: String, purpose: String): String {
        return "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" +
                "<PidOptions ver=\"1.0\" env=\"S\">\n" +
                "   <Opts fCount=\"\" fType=\"\" iCount=\"\" iType=\"\" pCount=\"\" pType=\"\" format=\"\" pidVer=\"2.0\" timeout=\"\" otp=\"\" wadh=\"sgydIC09zzy6f8Lb3xaAqzKquKe9lFcNR9uTvYxFp+A=\" posh=\"\" />\n" +
                "   <CustOpts>\n" +
                "      <Param name=\"txnId\" value=\"${txnId}\"/>\n" +
                "      <Param name=\"purpose\" value=\"$purpose\"/>\n" +
                "      <Param name=\"language\" value=\"en\"/>\n" +
                "   </CustOpts>\n" +
                "</PidOptions>"
    }

    fun invokeCaptureIntent() {
        val intent = Intent("in.gov.uidai.rdservice.face.CAPTURE")

        intent.putExtra("request", createPidOptions("1000", "auth"))

        startActivityForResult(intent, 123)
    }

    fun invokeLightingIntent() {
        val intent = Intent("in.gov.uidai.rdservice.face.CHECK_LIGHTING")

        intent.putExtra("request", "<checkLighingRequest txnId = \"1010\" language = \"en\"/>")

        startActivityForResult(intent, 123)
    }

    fun launchFaceMatchIntent(request: String) {
        val intent = Intent("in.gov.uidai.rdservice.face.MATCH")

        intent.putExtra("request", request)

        startActivityForResult(intent, 1233)

    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        data?.let {
            if (resultCode == Activity.RESULT_OK && requestCode == 1231) {
                handleLightingResponse(data.getStringExtra("response"));
            }
        }
    }

    fun handleLightingResponse(response: String?){
        val res = response?.toString() ?: ""
        print(res);
        RESULT = Regex("errCode = \"0\"").matches(res)
    }

}
