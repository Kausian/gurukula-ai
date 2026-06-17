package com.gurukula.gurukula_ai

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Native bridge for on-device GenAI (ML Kit GenAI running on Gemini Nano via
 * AICore). Exposed to Flutter over the "gurukula/ai" MethodChannel.
 *
 * Current behaviour: a fully working channel that reports the device as
 * "unsupported", so the Flutter side ([OnDeviceAiService]) transparently falls
 * back to the MockAiService. This is the correct result on emulators and on any
 * device without AICore + Gemini Nano, which is most devices today.
 *
 * To enable real on-device inference on a supported device (e.g. Pixel 8+/9 or
 * Galaxy S24+):
 *   1. Add ML Kit GenAI dependencies in android/app/build.gradle.kts and set
 *      minSdk to 26:
 *        implementation("com.google.mlkit:genai-summarization:<version>")
 *        implementation("com.google.mlkit:genai-rewriting:<version>")
 *        implementation("com.google.mlkit:genai-proofreading:<version>")
 *   2. Create the clients lazily, e.g.
 *        Summarization.getClient(SummarizerOptions.builder(context)...build())
 *        Rewriting.getClient(...) / Proofreading.getClient(...)
 *   3. checkAvailability(): combine each client's checkFeatureStatus():
 *        AVAILABLE -> "available"
 *        DOWNLOADABLE / DOWNLOADING -> "downloading"
 *        UNAVAILABLE -> "unsupported"
 *   4. summarize / proofread / rewrite(): call downloadFeature() if needed,
 *      then runInference(request) and reply with result.success(text). Run on a
 *      coroutine and post the reply back on the main thread.
 *   5. Close the clients in [dispose].
 *
 * The Flutter side already maps these status strings and falls back to the mock
 * per feature, so wiring the real calls requires no Dart changes.
 */
class GenAiBridge(flutterEngine: FlutterEngine) : MethodChannel.MethodCallHandler {

    private val channel = MethodChannel(
        flutterEngine.dartExecutor.binaryMessenger,
        CHANNEL,
    ).also { it.setMethodCallHandler(this) }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "checkAvailability" -> result.success(deviceStatus())

            // No on-device model available on this device. Signal an error so
            // the Flutter side uses the MockAiService fallback for this call.
            // TODO(phase5+): run the matching ML Kit GenAI inference here.
            "summarize", "proofread", "rewrite" ->
                result.error(
                    "unavailable",
                    "On-device AI is not available on this device",
                    null,
                )

            else -> result.notImplemented()
        }
    }

    /**
     * Reports whether on-device GenAI is usable.
     *
     * TODO(phase5+): replace with the combined ML Kit GenAI feature status of
     * the summarization, rewriting and proofreading clients.
     */
    private fun deviceStatus(): String = "unsupported"

    fun dispose() {
        channel.setMethodCallHandler(null)
    }

    companion object {
        private const val CHANNEL = "gurukula/ai"
    }
}
