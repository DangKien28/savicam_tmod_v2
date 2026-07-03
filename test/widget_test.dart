// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:savicam_tmod_v2/main.dart';
import 'package:savicam_tmod_v2/widgets/sos_button.dart';

void main() {
  testWidgets('SaViCam T-Mod main screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SaViCamApp());

    // Đảm bảo PageView được hiển thị
    expect(find.byType(PageView), findsOneWidget);

    // Đảm bảo nút SOS được hiển thị ở màn hình chính
    expect(find.byType(SOSButton), findsOneWidget);
    expect(find.text('SOS'), findsOneWidget);

    // Kiểm tra thanh trạng thái
    expect(find.text('CAMERA'), findsOneWidget);
    expect(find.text('GPS'), findsOneWidget);
  });
}
