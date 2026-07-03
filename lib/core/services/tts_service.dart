import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

class TTSService {
  static final TTSService instance = TTSService._privateConstructor();
  TTSService._privateConstructor();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;

  Future<void> init() async {
    await _flutterTts.setLanguage("vi-VN");
    await _flutterTts.setSpeechRate(0.5); // Tốc độ đọc thông thường
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
    });

    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
    });

    _flutterTts.setErrorHandler((msg) {
      _isSpeaking = false;
      debugPrint("Lỗi TTS Service: $msg");
    });
  }

  /// Phát âm thanh hội thoại thông thường với Agent
  Future<void> speak(String text) async {
    if (_isSpeaking) {
      await _flutterTts.stop();
    }
    await _flutterTts.speak(text);
  }

  /// Preemptive Alert: Ngắt luồng hiện tại để phát cảnh báo gắt
  Future<void> preemptiveAlert(String warningText) async {
    debugPrint("!!! PREEMPTIVE MULTITASKING: NGẮT LUỒNG TTS ĐỂ CẢNH BÁO !!!");
    
    // Ép dừng mọi tác vụ đọc hiện tại
    await _flutterTts.stop();
    
    // Đẩy tốc độ đọc lên nhanh và nâng cao độ (Pitch) để tạo sự chú ý
    await _flutterTts.setSpeechRate(0.8);
    await _flutterTts.setPitch(1.3);
    
    await _flutterTts.speak(warningText);

    // Trả cấu hình về bình thường sau khi xử lý xong sự kiện
    await Future.delayed(const Duration(seconds: 2));
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
  }
}