import 'package:flutter/material.dart';

class MovementView extends StatelessWidget {
  const MovementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blue.shade700,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_walk, size: 80, color: Colors.white),
          SizedBox(height: 20),
          Text(
            "DI CHUYỂN",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 15),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              "Nhận diện môi trường, cảnh báo chướng ngại và hỗ trợ định hướng khi di chuyển",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}