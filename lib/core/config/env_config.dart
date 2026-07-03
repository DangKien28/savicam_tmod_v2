import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static Future<void> init() async {
    // Tải file .env lên bộ nhớ
    await dotenv.load(fileName: ".env");
  }

  // Cung cấp các getter an toàn, nếu thiếu biến sẽ báo lỗi ngay lập tức
  static String get supabaseUrl {
    return dotenv.env['SUPABASE_URL'] ?? (throw Exception('Không tìm thấy SUPABASE_URL trong .env'));
  }

  static String get supabaseAnonKey {
    return dotenv.env['SUPABASE_ANON_KEY'] ?? (throw Exception('Không tìm thấy SUPABASE_ANON_KEY trong .env'));
  }
}