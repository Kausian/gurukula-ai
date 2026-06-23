package com.gurukula.gurukula_ai

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
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
