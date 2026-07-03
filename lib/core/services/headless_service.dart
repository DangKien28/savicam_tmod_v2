import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

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

    // Vòng lặp Core Loop: Ép thiết bị duy trì tốc độ ~20 FPS (50ms/tick) 
    // để nhồi ảnh vào YOLOv8n và tính toán RiskAssessment liên tục
    Timer.periodic(const Duration(milliseconds: 50), (timer) async {
      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          // TODO: Gọi hàm lấy frame từ Camera
          // TODO: NativeAIService.instance.runInference()
          // TODO: RiskAssessmentEngine.evaluateRisk()
          // Dữ liệu telemetry sẽ được SupabaseService đẩy đi tại đây
        }
      }
    });
  }
}