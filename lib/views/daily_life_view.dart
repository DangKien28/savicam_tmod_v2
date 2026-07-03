import 'package:flutter/material.dart';

class DailyLifeView extends StatelessWidget {
  const DailyLifeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.amber.shade700,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.center_focus_strong, size: 80, color: Colors.white),
          SizedBox(height: 20),
          Text(
            "SINH HOẠT",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 15),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              "Đọc văn bản, nhận diện vật thể, hỗ trợ các tác vụ sinh hoạt hằng ngày",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}