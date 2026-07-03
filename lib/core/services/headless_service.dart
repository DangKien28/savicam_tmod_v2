import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'native_ai_service.dart';
import '../algorithms/risk_assessment.dart';

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

    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    bool isProcessing = false;

    // Vòng lặp Core Loop: Ép thiết bị duy trì tốc độ ~20 FPS (50ms/tick) 
    // để nhồi ảnh vào YOLOv8n và tính toán RiskAssessment liên tục
    Timer.periodic(const Duration(milliseconds: 50), (timer) async {
      if (isProcessing) return;

      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          isProcessing = true;
          try {
            // TODO: Gọi hàm lấy frame từ Camera
            // Tạm thời giả lập frame
            Uint8List dummyFrame = Uint8List(0);

            // Chạy AI Inference
            final predictions = await aiService.runInference(dummyFrame, 640, 640);

            // Đánh giá rủi ro
            // (Giả lập logic bóc tách khoảng cách và vận tốc từ predictions)
            if (predictions.isNotEmpty) {
               // Giả lập có vật cản ở 2.0m, tốc độ tiến lại 1.0m/s
               riskEngine.evaluateRisk(2.0, 1.0);
            }
            
            // Dữ liệu telemetry sẽ được SupabaseService đẩy đi tại đây
          } finally {
            isProcessing = false;
          }
        }
      }
    });
  }
}