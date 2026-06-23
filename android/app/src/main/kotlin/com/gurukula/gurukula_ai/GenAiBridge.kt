package com.gurukula.gurukula_ai

import android.content.Context
import androidx.core.content.ContextCompat
import com.google.mlkit.genai.common.FeatureStatus
import com.google.mlkit.genai.summarization.Summarization
import com.google.mlkit.genai.summarization.SummarizerOptions
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Native bridge for on-device GenAI (ML Kit GenAI running on Gemini Nano via
 * AICore). Exposed to Flutter over the "gurukula/ai" MethodChannel.
 *
 * Phase 16A wires a REAL availability check via ML Kit GenAI's
 * checkFeatureStatus(). Generation is intentionally NOT wired yet:
 * summarize/proofread/rewrite still return an error so the Flutter side
 * ([OnDeviceAiService]) keeps using the MockAiService. This keeps the whole
 * study flow working on every device while surfacing the true on-device AI
 * status (Available / Downloadable / Downloading / Not supported) in Profile.
 */
class GenAiBridge(
    flutterEngine: FlutterEngine,
    private val context: Context,
) : MethodChannel.MethodCallHandler {

    private val channel = MethodChannel(
        flutterEngine.dartExecutor.binaryMessenger,
        CHANNEL,
    ).also { it.setMethodCallHandler(this) }

    // Created lazily so devices without AICore never construct a client.
    private val summarizer by lazy {
        Summarization.getClient(SummarizerOptions.builder(context).build())
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "checkAvailability" -> checkAvailability(result)

            // No on-device generation yet (Phase 16A is status-only). Signal an
            // error so the Flutter side uses the MockAiService fallback.
            "summarize", "proofread", "rewrite" ->
                result.error(
                    "unavailable",
                    "On-device generation is not enabled yet",
                    null,
                )

            else -> result.notImplemented()
        }
    }

    /**
     * Reports the real on-device GenAI status using the summarization feature as
     * a proxy (all ML Kit GenAI features share the same Gemini Nano base model).
     * Any failure degrades to "unsupported" so the app stays on the fallback.
     */
    private fun checkAvailability(result: MethodChannel.Result) {
        try {
            // ML Kit GenAI returns a Guava ListenableFuture. Consume it with its
            // own addListener/get (no Guava helper classes on the classpath), and
            // reply on the main thread (MethodChannel results must reply there).
            val future = summarizer.checkFeatureStatus()
            future.addListener({
                val status: Int = try {
                    future.get() ?: FeatureStatus.UNAVAILABLE
                } catch (_: Throwable) {
                    FeatureStatus.UNAVAILABLE
                }
                result.success(mapStatus(status))
            }, ContextCompat.getMainExecutor(context))
        } catch (e: Throwable) {
            result.success("unsupported")
        }
    }

    private fun mapStatus(status: Int): String = when (status) {
        FeatureStatus.AVAILABLE -> "available"
        FeatureStatus.DOWNLOADABLE -> "downloadable"
        FeatureStatus.DOWNLOADING -> "downloading"
        else -> "unsupported"
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
        try {
            summarizer.close()
        } catch (_: Throwable) {
            // Client may never have been initialized; ignore.
        }
    }

    companion object {
        private const val CHANNEL = "gurukula/ai"
    }
}
