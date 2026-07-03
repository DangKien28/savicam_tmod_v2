package com.example.savicam_tmod_v2

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    // Tên kênh phải khớp 100% với file native_ai_service.dart
    private val CHANNEL = "savicam.tmod/ai_engine"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Thiết lập lắng nghe MethodChannel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "loadTFLiteModel") { // Đã sửa lại khớp với tên hàm trong Dart
                // Nhận tên file mô hình từ Flutter
                val modelPath = call.argument<String>("modelPath")
                
                if (modelPath != null) {
                    val isSuccess = initTFLiteModel(modelPath)
                    if (isSuccess) {
                        result.success(true) // Trả về true cho Flutter
                    } else {
                        result.error("LOAD_FAILED", "Không thể khởi tạo Interpreter", null)
                    }
                } else {
                    result.error("INVALID_ARGS", "Thiếu đường dẫn mô hình", null)
                }
            } else if (call.method == "runInference") {
                // Khung chờ sẵn cho bước sau: Nhận frame ảnh và suy luận
                result.notImplemented()
            } else {
                result.notImplemented() // Báo lỗi nếu gọi sai tên hàm
            }
        }
    }

    // Hàm nạp mô hình TFLite (Tạm thời dựng khung)
    private fun initTFLiteModel(modelPath: String): Boolean {
        return try {
            // TODO: Ở bước tiếp theo, chúng ta sẽ thêm thư viện TFLite 
            // và khởi tạo Interpreter với NNAPI delegate tại đây.
            
            println("Native đã nhận lệnh nạp mô hình: \$modelPath")
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }
}