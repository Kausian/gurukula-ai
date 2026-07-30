package com.gurukula.gurukula_ai

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

// FlutterFragmentActivity (not FlutterActivity) is required by local_auth for
// the biometric prompt on Android (v1.21.0 Privacy Lock). MethodChannels such
// as the GenAiBridge are unaffected.
class MainActivity : FlutterFragmentActivity() {
    private var genAiBridge: GenAiBridge? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Registers the "gurukula/ai" MethodChannel for on-device AI.
        genAiBridge = GenAiBridge(flutterEngine, applicationContext)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        genAiBridge?.dispose()
        genAiBridge = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
