class RiskAssessmentEngine {
  static const double THRESHOLD_LEVEL_1 = 1.5; // Dưới 1.5 giây -> Mức 1 (Cực kỳ nguy hiểm)
  static const double THRESHOLD_LEVEL_2 = 3.0; // Dưới 3.0 giây -> Mức 2 (Nguy hiểm)

  /// Đánh giá rủi ro dựa trên TTC (Khoảng cách / Tốc độ tương đối)
  /// distanceToObstacle: Tính bằng mét (m)
  /// relativeVelocity: Tính bằng mét/giây (m/s)
  String evaluateRisk(double distanceToObstacle, double relativeVelocity) {
    if (relativeVelocity <= 0) {
      return "SAFE"; // Vật thể đang đứng yên hoặc di chuyển ra xa
    }

    double ttc = distanceToObstacle / relativeVelocity;

    if (ttc <= THRESHOLD_LEVEL_1) {
      _triggerPreemptiveAlert("LÙI LẠI NGAY LẬP TỨC!", true);
      return "CRITICAL";
    } else if (ttc <= THRESHOLD_LEVEL_2) {
      _triggerPreemptiveAlert("CÓ VẬT CẢN PHÍA TRƯỚC!", false);
      return "WARNING";
    }

    return "SAFE";
  }

  void _triggerPreemptiveAlert(String message, bool maxVibration) {
    // TODO: Tích hợp logic ngắt luồng Text-to-Speech (Preemptive Multitasking)
    // TODO: Phát âm thanh cảnh báo gắt (tiếng beep lớn)
    
    if (maxVibration) {
      // TODO: Kích hoạt rung cường độ cao
      print("!!! CẢNH BÁO MỨC 1: $message !!!");
    } else {
      print("! CẢNH BÁO MỨC 2: $message !");
    }
  }
}