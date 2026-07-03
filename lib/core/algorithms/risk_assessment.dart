import 'package:flutter/foundation.dart';
import '../services/tts_service.dart';
import '../services/vibration_service.dart';

class RiskAssessmentEngine {
  static const double thresholdLevel1 = 1.5; // Dưới 1.5 giây -> Mức 1 (Cực kỳ nguy hiểm)
  static const double thresholdLevel2 = 3.0; // Dưới 3.0 giây -> Mức 2 (Nguy hiểm)
  static const double thresholdLevel3 = 5.0; // Dưới 5.0 giây -> Mức 3 (Cảnh báo)

  /// Đánh giá rủi ro dựa trên TTC (Khoảng cách / Tốc độ tương đối)
  /// distanceToObstacle: Tính bằng mét (m)
  /// relativeVelocity: Tính bằng mét/giây (m/s)
  String evaluateRisk(double distanceToObstacle, double relativeVelocity) {
    if (relativeVelocity <= 0) {
      return "SAFE"; // Vật thể đang đứng yên hoặc di chuyển ra xa
    }

    double ttc = distanceToObstacle / relativeVelocity;

    if (ttc <= thresholdLevel1) {
      _triggerPreemptiveAlert("LÙI LẠI NGAY LẬP TỨC!", 1);
      return "CRITICAL";
    } else if (ttc <= thresholdLevel2) {
      _triggerPreemptiveAlert("CÓ VẬT CẢN PHÍA TRƯỚC!", 2);
      return "DANGER";
    } else if (ttc <= thresholdLevel3) {
      _triggerPreemptiveAlert("Chú ý phía trước", 3);
      return "WARNING";
    }

    // Mức 4 (An Toàn > 5.0s): dừng rung, AI im lặng
    VibrationService.instance.stopVibration();
    return "SAFE";
  }

  /// Kích hoạt cảnh báo khẩn cấp theo cấp độ rủi ro (NCKH §3.1 — Preemptive Multitasking)
  void _triggerPreemptiveAlert(String message, int level) {
    // Ưu tiên 1: Ngắt mọi rung đang chạy, phát rung pattern đúng mức
    VibrationService.instance.stopVibration();
    switch (level) {
      case 1:
        // Mức 1: rung giật cục liên tục — dừng/lùi theo phản xạ
        VibrationService.instance.vibrateLevel1();
        debugPrint("!!! CẢNH BÁO MỨC 1 (CRITICAL): $message !!!");
      case 2:
        // Mức 2: rung mạnh ngắt quãng — đổi hướng/hạ trọng tâm
        VibrationService.instance.vibrateLevel2();
        debugPrint("!! CẢNH BÁO MỨC 2 (DANGER): $message !!");
      case 3:
        // Mức 3: rung nhịp đều nhẹ — đi chậm, dùng gậy dò
        VibrationService.instance.vibrateLevel3();
        debugPrint("! CẢNH BÁO MỨC 3 (WARNING): $message !");
    }

    // Ưu tiên 2: Ngắt luồng TTS hiện tại và phát cảnh báo bằng giọng nói
    TTSService.instance.preemptiveAlert(message);
  }
}