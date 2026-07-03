import 'package:flutter/material.dart';

class SafetyAssistantView extends StatelessWidget {
  const SafetyAssistantView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.green.shade700,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield, size: 80, color: Colors.white),
          SizedBox(height: 20),
          Text(
            "TRỢ LÝ AN TOÀN",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 15),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              "AI nhận diện môi trường, cảnh báo vật cản và nguy hiểm xung quanh",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}