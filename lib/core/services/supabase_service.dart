import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env_config.dart';

class SupabaseService {
  // Singleton pattern
  SupabaseService._privateConstructor();
  static final SupabaseService instance = SupabaseService._privateConstructor();

  // Biến giữ tham chiếu client
  late final SupabaseClient client;

  // Hàm khởi tạo, được gọi khi app mới bật lên
  Future<void> init() async {
    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      anonKey: EnvConfig.supabaseAnonKey,
    );
    client = Supabase.instance.client;
    print("Supabase đã được khởi tạo thành công!");
  }
}