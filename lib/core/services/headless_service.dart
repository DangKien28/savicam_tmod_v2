import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'native_ai_service.dart';
import '../algorithms/risk_assessment.dart';
import 'camera_service.dart';
import 'vibration_service.dart';

class HeadlessService {
  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'savicam_tmod_foreground',
        initialNotificationTitle: 'SaViCam T-Mod',
        initialNotificationContent: 'Hệ thống an toàn đang vận hành dưới nền.',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
      ),
    );

    service.startService();
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    // Đảm bảo bindings được khởi tạo trong isolate mới của background service
    WidgetsFlutterBinding.ensureInitialized();

    // Khởi tạo các Service và Algorithm phục vụ Core Loop
    final aiService = NativeAIService();
    final riskEngine = RiskAssessmentEngine();

    final isModelLoaded = await aiService.initializeModel();
    if (!isModelLoaded) {
      debugPrint("Warning: Không thể load mô hình AI, Core loop sẽ bị gián đoạn.");
    }

    // Khởi tạo Camera và bắt đầu frame stream
    await CameraService.instance.initialize();

    // Buffer frame mới nhất — được cập nhật từ camera stream
    Uint8List? latestFrame;
    int frameWidth = 640;
    int frameHeight = 640;

    if (CameraService.instance.isInitialized) {
      await CameraService.instance.startFrameStream((bytes, w, h) {
        // Cập nhật frame mới nhất, timer loop sẽ lấy tại tick tiếp theo
        latestFrame = bytes;
        frameWidth = w;
        frameHeight = h;
      });
    } else {
      debugPrint("HeadlessService: Camera chưa sẵn sàng — Core loop chạy không có video.");
    }

    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    service.on('stopService').listen((event) async {
      await CameraService.instance.stopFrameStream();
      VibrationService.instance.stopVibration();
      service.stopSelf();
    });

    bool isProcessing = false;

    // Vòng lặp Core Loop: ~20 FPS (50ms/tick)
    // Pipeline: CameraImage → NV21 → YOLOv8n TFLite (NPU) → TTC → Risk Alert
    Timer.periodic(const Duration(milliseconds: 50), (timer) async {
      if (isProcessing) return;

      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          // Chưa có frame → bỏ qua tick này
          final frame = latestFrame;
          if (frame == null || frame.isEmpty) return;

          isProcessing = true;
          try {
            // 1. Chạy YOLOv8n inference
            final predictions = await aiService.runInference(frame, frameWidth, frameHeight);

            if (predictions.isNotEmpty) {
              // 2. Bóc tách thông tin từ prediction đầu tiên (confidence cao nhất)
              // Format prediction từ TFLite Task API:
              // {'distance': double, 'relativeVelocity': double, 'label': String, 'confidence': double}
              final best = predictions.first as Map<dynamic, dynamic>;
              final distance = (best['distance'] as num?)?.toDouble() ?? 0.0;
              final velocity = (best['relativeVelocity'] as num?)?.toDouble() ?? 0.0;

              // 3. Đánh giá rủi ro TTC → kích hoạt TTS + Vibration
              riskEngine.evaluateRisk(distance, velocity);
            }

            // 4. Dữ liệu telemetry sẽ được SupabaseService đẩy đi tại đây
          } finally {
            isProcessing = false;
          }
        }
      }
    });
  }
}
