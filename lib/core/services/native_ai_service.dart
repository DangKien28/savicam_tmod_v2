import 'package:flutter/services.dart';

class NativeAIService {
  static const MethodChannel _channel = MethodChannel('savicam.tmod/ai_engine');

  /// Khởi tạo mô hình YOLOv8n INT8, ép thiết bị sử dụng NNAPI/NPU
  Future<bool> initializeModel() async {
    try {
      final bool result = await _channel.invokeMethod('loadTFLiteModel', {
        'modelPath': 'assets/models/yolov8n_int8.tflite',
        'useNNAPI': true, 
        'numThreads': 4,
      });
      return result;
    } on PlatformException catch (e) {
      print("Lỗi khởi tạo AI Model: '${e.message}'.");
      return false;
    }
  }

  /// Gửi frame ảnh dạng byte array xuống Native để suy luận
  Future<List<dynamic>> runInference(Uint8List imageBytes, int width, int height) async {
    try {
      final List<dynamic> predictions = await _channel.invokeMethod('runInference', {
        'imageBytes': imageBytes,
        'width': width,
        'height': height,
      });
      return predictions;
    } on PlatformException catch (e) {
      print("Lỗi suy luận: '${e.message}'.");
      return [];
    }
  }
}