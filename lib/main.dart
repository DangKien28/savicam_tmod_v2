import 'package:flutter/material.dart';
import 'package:savicam_tmod_v2/screens/pairing_screen.dart';
import 'screens/main_screen.dart';
import 'core/config/env_config.dart';
import 'core/services/supabase_service.dart';

import 'core/services/headless_service.dart';
import 'core/services/tts_service.dart';

Future<void> main() async {
  // Bắt buộc phải có dòng này khi gọi các hàm async (như đọc file .env hay gọi Supabase) trước runApp
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 1. Tải biến môi trường từ file .env
    await EnvConfig.init();

    // 2. Khởi tạo dịch vụ Supabase để sẵn sàng bắn tín hiệu sang Relap
    await SupabaseService.instance.init();
    
    // 3. Khởi tạo TTS Service
    await TTSService.instance.init();

    // 4. Khởi động background service (Core Loop)
    await HeadlessService.initializeService();
    
  } catch (e) {
    debugPrint("Lỗi khởi tạo hệ thống: $e");
    // Nếu lỗi, bác có thể log ra hoặc hiển thị 1 màn hình báo lỗi mất kết nối ở đây
  }

  // Khởi chạy app SaViCam T-Mod
  runApp(const SaViCamApp());
}

class SaViCamApp extends StatelessWidget {
  const SaViCamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SaViCam T-Mod',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      // Gọi MainScreen chứa PageView và nút SOS mà chúng ta đã dựng
      home: const PairingScreen(), 
    );
  }
}