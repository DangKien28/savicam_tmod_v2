import 'package:flutter/material.dart';
import '../widgets/sos_button.dart';
import '../views/safety_assistant_view.dart';
import '../views/movement_view.dart';
import '../views/daily_life_view.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentIndex = 0;

  // Danh sách các view đã được phân tách thành các file riêng biệt
  final List<Widget> _views = [
    const SafetyAssistantView(),
    const MovementView(),
    const DailyLifeView(),
  ];

  final List<Color> _indicatorColors = [
    Colors.green,
    Colors.blue,
    Colors.amber,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 1. Hệ thống trạng thái cố định ở trên cùng
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(children: [Icon(Icons.camera_alt, size: 18), SizedBox(width: 4), Text("CAMERA")]),
                  Row(children: [Icon(Icons.location_on, size: 18), SizedBox(width: 4), Text("GPS")]),
                  Row(children: [Icon(Icons.psychology, size: 18), SizedBox(width: 4), Text("AI")]),
                  Row(children: [Icon(Icons.cloud, size: 18), SizedBox(width: 4), Text("CLOUD")]),
                  Row(children: [Icon(Icons.battery_full, size: 18), SizedBox(width: 4), Text("100%")]),
                ],
              ),
            ),
            
            // 2. Khu vực trượt ngang chứa các View riêng lẻ
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: _views.length,
                itemBuilder: (context, index) {
                  return _views[index];
                },
              ),
            ),

            // 3. Thanh chấm chỉ báo trang hiện tại
            _buildPageIndicator(),

            // 4. Khối nút SOS luôn nằm ở đáy, không bị ảnh hưởng bởi thao tác vuốt ngang
            const SOSButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _views.length,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 6.0),
            width: _currentIndex == index ? 14.0 : 8.0,
            height: _currentIndex == index ? 14.0 : 8.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentIndex == index ? _indicatorColors[index] : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }
}