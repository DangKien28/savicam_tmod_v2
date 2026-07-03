import 'package:flutter/foundation.dart';
import '../services/tts_service.dart';

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
      _triggerPreemptiveAlert("LÙI LẠI NGAY LẬP TỨC!", true, 1);
      return "CRITICAL";
    } else if (ttc <= thresholdLevel2) {
      _triggerPreemptiveAlert("CÓ VẬT CẢN PHÍA TRƯỚC!", false, 2);
      return "DANGER";
    } else if (ttc <= thresholdLevel3) {
      _triggerPreemptiveAlert("Chú ý phía trước", false, 3);
      return "WARNING";
    }

    return "SAFE";
  }

  void _triggerPreemptiveAlert(String message, bool maxVibration, int level) {
    // Ngắt luồng Text-to-Speech hiện tại và phát cảnh báo
    TTSService.instance.preemptiveAlert(message);

    // TODO: Phát âm thanh cảnh báo gắt (tiếng beep lớn)
    
    if (maxVibration) {
      // TODO: Kích hoạt rung cường độ cao
      debugPrint("!!! CẢNH BÁO MỨC 1: $message !!!");
    } else {
      debugPrint("! CẢNH BÁO MỨC $level: $message !");
    }
  }
}