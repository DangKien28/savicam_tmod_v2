package com.example.savicam_tmod_v2

import android.graphics.BitmapFactory
import android.graphics.ImageFormat
import android.graphics.Rect
import android.graphics.YuvImage
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.tensorflow.lite.task.core.BaseOptions
import org.tensorflow.lite.task.vision.detector.Detection
import org.tensorflow.lite.task.vision.detector.ObjectDetector
import org.tensorflow.lite.support.image.TensorImage
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {

    // Kênh phải khớp với bên Flutter: NativeAIService._channel
    private val CHANNEL = "savicam.tmod/ai_engine"
    private var objectDetector: ObjectDetector? = null

    // Pinhole Camera Model constants
    // focal length ước lượng (px) cho smartphone camera 35mm-equivalent
    private val FOCAL_LENGTH_PX = 800.0
    // Chiều rộng vật thể tham chiếu (m): người đi bộ / xe đạp ≈ 0.5m
    private val REFERENCE_WIDTH_M = 0.5

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "loadTFLiteModel" -> {
                        val modelPath = call.argument<String>("modelPath")
                            ?: "assets/models/yolov8n_int8.tflite"
                        val useNNAPI = call.argument<Boolean>("useNNAPI") ?: true
                        val numThreads = call.argument<Int>("numThreads") ?: 4
                        result.success(loadModel(modelPath, useNNAPI, numThreads))
                    }
                    "runInference" -> {
                        val imageBytes = call.argument<ByteArray>("imageBytes")
                        val width = call.argument<Int>("width") ?: 640
                        val height = call.argument<Int>("height") ?: 640
                        if (imageBytes == null || imageBytes.isEmpty()) {
                            result.success(emptyList<Map<String, Any>>())
                            return@setMethodCallHandler
                        }
                        result.success(runInference(imageBytes, width, height))
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * Load mô hình YOLOv8n TFLite từ Flutter assets.
     * Dùng NNAPI delegate để tăng tốc trên NPU (Android 8.1+) theo NCKH §1.2.1.
     */
    private fun loadModel(modelPath: String, useNNAPI: Boolean, numThreads: Int): Boolean {
        return try {
            // Copy model từ Flutter assets sang filesDir (TFLite Task API yêu cầu file path thật)
            val modelFile = copyAssetToFile(modelPath)

            val baseOptions = BaseOptions.builder()
                .setNumThreads(numThreads)
                .apply { if (useNNAPI) useNnapi() }
                .build()

            val options = ObjectDetector.ObjectDetectorOptions.builder()
                .setBaseOptions(baseOptions)
                .setMaxResults(10)         // Tối đa 10 detection/frame
                .setScoreThreshold(0.45f)  // Lọc detection yếu < 45% confidence
                .build()

            objectDetector = ObjectDetector.createFromFileAndOptions(modelFile, options)
            android.util.Log.d("SaViCam", "✅ YOLOv8n TFLite loaded: $modelPath (NNAPI=$useNNAPI)")
            true
        } catch (e: Exception) {
            android.util.Log.e("SaViCam", "❌ Load model error: ${e.message}")
            false
        }
    }

    /**
     * Inference trên frame NV21 bytes từ CameraService.
     * Trả về List prediction với khoảng cách ước tính (Pinhole Camera Model).
     *
     * Output format cho Dart:
     * {'label': String, 'confidence': double, 'distance': double,
     *  'relativeVelocity': double, 'bbox_*': double}
     */
    private fun runInference(nv21Bytes: ByteArray, width: Int, height: Int): List<Map<String, Any>> {
        val detector = objectDetector ?: return emptyList()

        return try {
            // 1. Decode NV21 → JPEG → Bitmap
            val yuvImage = YuvImage(nv21Bytes, ImageFormat.NV21, width, height, null)
            val baos = ByteArrayOutputStream()
            yuvImage.compressToJpeg(Rect(0, 0, width, height), 90, baos)
            val bitmap = BitmapFactory.decodeByteArray(baos.toByteArray(), 0, baos.size())

            // 2. TensorImage từ Bitmap
            val tensorImage = TensorImage.fromBitmap(bitmap)

            // 3. Run Object Detection
            val detections: List<Detection> = detector.detect(tensorImage)

            // 4. Map kết quả → Dart-compatible Map
            detections.map { detection ->
                val bbox = detection.boundingBox
                val bboxWidthPx = bbox.width()

                // Pinhole Camera Model: distance(m) = (refWidth * focalLength) / bboxWidthPx
                val distanceM = if (bboxWidthPx > 0)
                    (REFERENCE_WIDTH_M * FOCAL_LENGTH_PX) / bboxWidthPx
                else 99.0

                // relativeVelocity: ước lượng 0.5 m/s (placeholder)
                // Production: dùng ByteTrack/SORT tracking giữa các frame để tính velocity thật
                val relativeVelocity = 0.5

                mapOf(
                    "label"            to (detection.categories.firstOrNull()?.label ?: "unknown"),
                    "confidence"       to (detection.categories.firstOrNull()?.score?.toDouble() ?: 0.0),
                    "distance"         to distanceM,
                    "relativeVelocity" to relativeVelocity,
                    "bbox_left"        to bbox.left.toDouble(),
                    "bbox_top"         to bbox.top.toDouble(),
                    "bbox_right"       to bbox.right.toDouble(),
                    "bbox_bottom"      to bbox.bottom.toDouble(),
                )
            }
        } catch (e: Exception) {
            android.util.Log.e("SaViCam", "❌ Inference error: ${e.message}")
            emptyList()
        }
    }

    /**
     * Copy Flutter asset sang filesDir để TFLite Task API đọc được.
     * Bỏ qua nếu file đã tồn tại (tránh copy lại mỗi lần khởi động).
     */
    private fun copyAssetToFile(assetPath: String): File {
        val fileName = assetPath.substringAfterLast("/")
        val outFile = File(filesDir, fileName)
        if (!outFile.exists()) {
            assets.open(assetPath).use { input ->
                FileOutputStream(outFile).use { output ->
                    input.copyTo(output)
                }
            }
        }
        return outFile
    }
}