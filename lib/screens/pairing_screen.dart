import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/services/supabase_service.dart';
import 'main_screen.dart';

class PairingScreen extends StatefulWidget {
  const PairingScreen({super.key});

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  String _pairingCode = "------";
  bool _isPaired = false;
  
  // Định danh thiết bị T-Mod (Khớp với cột tmod_mac_address)
  final String _tmodDeviceId = 'tmod_primary_mac';

  @override
  void initState() {
    super.initState();
    _initializePairing();
  }

  Future<void> _initializePairing() async {
    final client = SupabaseService.instance.client;

    // 1. Tạo mã PIN 6 chữ số ngẫu nhiên
    final random = Random();
    final code = (100000 + random.nextInt(900000)).toString();
    
    setState(() {
      _pairingCode = code;
    });

    try {
      // 2. Xóa các phiên kết nối cũ của thiết bị này
      await client
          .from('device_pairs')
          .delete()
          .eq('tmod_mac_address', _tmodDeviceId);

      // 3. Tạo một bản ghi mới lên Supabase
      // Đã sửa: Khớp 100% với file SQL -> Dùng 'pending' thay vì 'WAITING'
      await client.from('device_pairs').insert({
        'tmod_mac_address': _tmodDeviceId,
        'pairing_code': _pairingCode,
        'status': 'pending', 
        // Không truyền 'relap_user_id' -> Database sẽ tự động set là NULL
        // Không truyền 'created_at' -> Database tự động lấy hàm now() theo chuẩn UTC
      });

      debugPrint("Đã tạo mã PIN: $_pairingCode. Đang chờ Relap kết nối...");

      // 4. Mở luồng WebSockets Realtime lắng nghe sự thay đổi
      client
          .from('device_pairs')
          .stream(primaryKey: ['id']) 
          .eq('tmod_mac_address', _tmodDeviceId)
          .listen((List<Map<String, dynamic>> data) {
        if (data.isNotEmpty) {
          final status = data.first['status'];
          
          // Đã sửa: Khớp 100% với file SQL -> Lắng nghe 'paired' thay vì 'PAIRED'
          if (status == 'paired' && !_isPaired) {
            _handleSuccessfulPairing();
          }
        }
      });
    } catch (e) {
      debugPrint("Lỗi luồng kết nối Supabase Realtime: $e");
    }
  }

  void _handleSuccessfulPairing() {
    setState(() {
      _isPaired = true;
    });

    HapticFeedback.heavyImpact();
    debugPrint("KẾT NỐI RELAP THÀNH CÔNG! Đang khởi động hệ thống T-Mod...");

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.phonelink_ring_rounded,
                  size: 80,
                  color: _isPaired ? Colors.green : Colors.blueAccent,
                ),
                const SizedBox(height: 30),
                Text(
                  _isPaired ? "ĐÃ KẾT NỐI!" : "CHỜ KẾT NỐI RELAP",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _isPaired ? Colors.green : Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Đọc mã 6 số này cho người thân\nđể nhập vào ứng dụng SaViCam Relap",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 50),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isPaired ? Colors.green : Colors.blueAccent,
                      width: 3,
                    ),
                  ),
                  child: Text(
                    _pairingCode,
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 8.0,
                      color: _isPaired ? Colors.green : Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                if (!_isPaired)
                  const CircularProgressIndicator(
                    color: Colors.blueAccent,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}