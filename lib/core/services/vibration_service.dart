import 'package:vibration/vibration.dart';
import 'package:flutter/foundation.dart';

/// Dịch vụ rung theo mức rủi ro TTC — Cơ chế Ghi đè khẩn cấp (NCKH §3.1)
///
/// Mức 1 (CRITICAL < 1.5s): rung giật cục liên tục
/// Mức 2 (DANGER  1.5–3.0s): rung mạnh ngắt quãng
/// Mức 3 (WARNING 3.0–5.0s): rung nhịp đều nhẹ
class VibrationService {
  static final VibrationService instance = VibrationService._privateConstructor();
  VibrationService._privateConstructor();

  bool _hasVibrator = false;
  bool _hasAmplitudeControl = false;

  /// Khởi tạo: kiểm tra phần cứng thiết bị có hỗ trợ rung không
  Future<void> init() async {
    _hasVibrator = await Vibration.hasVibrator() == true;
    _hasAmplitudeControl = await Vibration.hasAmplitudeControl() == true;
    debugPrint(
      "VibrationService: hasVibrator=$_hasVibrator, hasAmplitudeControl=$_hasAmplitudeControl",
    );
  }

  /// Mức 1 — Ghi đè tối cao: rung giật cục liên tục (CRITICAL)
  /// pattern: [delay, vibrate, pause, vibrate, pause, vibrate] ms
  void vibrateLevel1() {
    if (!_hasVibrator) return;
    Vibration.vibrate(
      pattern: [0, 500, 100, 500, 100, 500, 100, 500],
      intensities: _hasAmplitudeControl ? [0, 255, 0, 255, 0, 255, 0, 255] : [],
    );
    debugPrint("VibrationService: LEVEL 1 — Rung giật cục liên tục");
  }

  /// Mức 2 — Nguy hiểm cao: rung mạnh ngắt quãng (DANGER)
  void vibrateLevel2() {
    if (!_hasVibrator) return;
    Vibration.vibrate(
      pattern: [0, 400, 200, 400, 200, 400],
      intensities: _hasAmplitudeControl ? [0, 200, 0, 200, 0, 200] : [],
    );
    debugPrint("VibrationService: LEVEL 2 — Rung mạnh ngắt quãng");
  }

  /// Mức 3 — Cảnh báo: rung nhịp đều nhẹ (WARNING)
  void vibrateLevel3() {
    if (!_hasVibrator) return;
    Vibration.vibrate(
      pattern: [0, 200, 300, 200],
      intensities: _hasAmplitudeControl ? [0, 128, 0, 128] : [],
    );
    debugPrint("VibrationService: LEVEL 3 — Rung nhịp đều nhẹ");
  }

  /// Dừng rung ngay lập tức
  void stopVibration() {
    if (!_hasVibrator) return;
    Vibration.cancel();
  }
}
