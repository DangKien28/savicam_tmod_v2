
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

/// Dịch vụ quản lý Camera — cung cấp frame thô cho YOLOv8n (NCKH §3.2.1)
///
/// Chạy trong main isolate; cung cấp bytes qua callback để
/// HeadlessService chuyển sang background service.
///
/// Pipeline: Camera → CameraImage (YUV420) → NV21 bytes → NativeAIService
class CameraService {
  static final CameraService instance = CameraService._privateConstructor();
  CameraService._privateConstructor();

  CameraController? _controller;
  bool _isStreaming = false;

  /// Khởi tạo camera sau (back camera) với độ phân giải trung bình
  Future<void> initialize() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      debugPrint("CameraService: Không tìm thấy camera nào trên thiết bị.");
      return;
    }

    // Ưu tiên camera sau (back camera)
    final backCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      backCamera,
      ResolutionPreset.medium, // ~480p — cân bằng FPS và độ chính xác YOLOv8n
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420, // Format YUV420 → dễ convert sang NV21
    );

    await _controller!.initialize();
    debugPrint("CameraService: Camera đã sẵn sàng — ${backCamera.name}");
  }

  /// Bắt đầu luồng frame, gọi [onFrame] với mỗi frame NV21 bytes
  Future<void> startFrameStream(void Function(Uint8List bytes, int width, int height) onFrame) async {
    if (_controller == null || !_controller!.value.isInitialized) {
      debugPrint("CameraService: Chưa khởi tạo, gọi initialize() trước.");
      return;
    }
    if (_isStreaming) return;

    _isStreaming = true;
    await _controller!.startImageStream((CameraImage image) {
      final nv21 = _convertYUV420toNV21(image);
      if (nv21 != null) {
        onFrame(nv21, image.width, image.height);
      }
    });
    debugPrint("CameraService: Bắt đầu frame stream.");
  }

  /// Dừng luồng frame
  Future<void> stopFrameStream() async {
    if (_isStreaming && _controller != null && _controller!.value.isStreamingImages) {
      await _controller!.stopImageStream();
      _isStreaming = false;
      debugPrint("CameraService: Đã dừng frame stream.");
    }
  }

  /// Giải phóng tài nguyên camera
  Future<void> dispose() async {
    await stopFrameStream();
    await _controller?.dispose();
    _controller = null;
  }

  bool get isInitialized => _controller?.value.isInitialized ?? false;
  bool get isStreaming => _isStreaming;

  /// Chuyển đổi CameraImage (YUV420) → NV21 byte array
  /// NV21 là format chuẩn cho TFLite Object Detection trên Android
  Uint8List? _convertYUV420toNV21(CameraImage image) {
    try {
      final yPlane = image.planes[0];
      final uPlane = image.planes[1];
      final vPlane = image.planes[2];

      final int ySize = yPlane.bytes.length;
      final int uvSize = uPlane.bytes.length + vPlane.bytes.length;
      final nv21 = Uint8List(ySize + uvSize);

      // Copy Y plane
      nv21.setRange(0, ySize, yPlane.bytes);

      // Interleave V và U (NV21: YYYY...VUVU...)
      int uvIndex = ySize;
      for (int i = 0; i < uPlane.bytes.length; i++) {
        nv21[uvIndex++] = vPlane.bytes[i];
        nv21[uvIndex++] = uPlane.bytes[i];
      }

      return nv21;
    } catch (e) {
      debugPrint("CameraService: Lỗi convert YUV420→NV21: $e");
      return null;
    }
  }
}
