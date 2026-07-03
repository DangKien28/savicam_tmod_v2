import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/services/supabase_service.dart';

class SOSButton extends StatefulWidget {
  const SOSButton({super.key});

  @override
  State<SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton> {
  Timer? _pressTimer;
  bool _isTriggered = false;

  void _handlePressDown(TapDownDetails details) {
    _isTriggered = false;
    // Rung nhẹ báo hiệu hệ thống bắt đầu đếm giờ
    HapticFeedback.lightImpact();

    _pressTimer = Timer(const Duration(seconds: 3), () async {
      _isTriggered = true;
      // Rung cực đại báo hiệu SOS thành công
      HapticFeedback.heavyImpact();

      debugPrint("KÍCH HOẠT MODULE SOS: Đang gửi cảnh báo khẩn cấp...");
      
      // Giả lập lấy tọa độ hiện tại (sau này thay bằng dữ liệu định vị thực tế)
      const double currentLat = 16.0544;
      const double currentLng = 108.2022;

      // Gọi Supabase Service để lưu dữ liệu
      await SupabaseService.instance.triggerEmergencyProtocol(currentLat, currentLng);
    });
  }

  void _handlePressUp(TapUpDetails details) {
    _cancelTimer();
  }

  void _handlePressCancel() {
    _cancelTimer();
  }

  void _cancelTimer() {
    if (_pressTimer != null && _pressTimer!.isActive) {
      _pressTimer!.cancel();
      if (!_isTriggered) {
        debugPrint("Đã hủy SOS do nhả tay quá sớm.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: GestureDetector(
        onTapDown: _handlePressDown,
        onTapUp: _handlePressUp,
        onTapCancel: _handlePressCancel,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone_in_talk, color: Colors.white, size: 30),
                  SizedBox(width: 10),
                  Text(
                    "SOS",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Text(
                "Nhấn và giữ 3 giây để kích hoạt",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}