import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
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
    debugPrint("Supabase đã được khởi tạo thành công!");
  }

  // Hàm xử lý kích hoạt khẩn cấp (Chặng 3)
  Future<void> triggerEmergencyProtocol(double lat, double lng) async {
    try {
      // 1. Lưu log sự kiện SOS vào bảng sos_events
      await client.from('sos_events').insert({
        'status': 'ACTIVE',
        'latitude': lat,
        'longitude': lng,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // 2. Cập nhật trạng thái thiết bị để Relap App bắt được qua WebSockets
      await client.from('device_telemetry').upsert({
        'device_id': 'tmod_primary',
        'is_sos_active': true,
        'last_lat': lat,
        'last_lng': lng,
      });
      debugPrint("ĐÃ ĐẨY DỮ LIỆU SOS LÊN SUPABASE THÀNH CÔNG!");
    } catch (e) {
      debugPrint("Lỗi khi gửi SOS lên Supabase: $e");
    }
  }
}