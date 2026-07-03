import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class OfflineMapService {
  static final OfflineMapService instance = OfflineMapService._privateConstructor();
  OfflineMapService._privateConstructor();

  Database? _database;

  // Cấu hình URL trỏ thẳng về Bucket trên Cloudflare R2
  final String _r2BucketUrl = "https://your-cloudflare-r2-url.com/osm_routing_data.db";

  /// Khởi tạo và kiểm tra trạng thái tệp bản đồ ngoại tuyến
  Future<void> initMapData() async {
    final dbPath = await _getDbPath();
    final file = File(dbPath);

    if (!await file.exists()) {
      debugPrint("Không tìm thấy Sổ tay lộ trình. Bắt đầu tải tệp OpenStreetMap từ Cloudflare R2...");
      await _downloadMapDataFromR2(dbPath);
    } else {
      debugPrint("Sổ tay lộ trình đã sẵn sàng trong bộ nhớ Edge.");
    }

    // Mở database ở chế độ Read-only để tăng tốc độ truy vấn
    _database = await openDatabase(dbPath, readOnly: true);
  }

  Future<String> _getDbPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return join(directory.path, 'osm_routing_data.db');
  }

  Future<void> _downloadMapDataFromR2(String savePath) async {
    try {
      final response = await http.get(Uri.parse(_r2BucketUrl));
      if (response.statusCode == 200) {
        final file = File(savePath);
        await file.writeAsBytes(response.bodyBytes);
        debugPrint("Tải và lưu bản đồ từ R2 thành công!");
      } else {
        debugPrint("Lỗi tải bản đồ: HTTP ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Lỗi khi kết nối đến Cloudflare R2: $e");
    }
  }

  /// Rule-based mapping: Chọc vào SQLite để trích xuất tọa độ
  Future<Map<String, dynamic>?> getLocationCoordinates(String locationName) async {
    if (_database == null) return null;
    
    final List<Map<String, dynamic>> maps = await _database!.query(
      'locations',
      columns: ['latitude', 'longitude'],
      where: 'name LIKE ?',
      whereArgs: ['%$locationName%'],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }
}