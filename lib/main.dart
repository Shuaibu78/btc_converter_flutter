import 'package:flutter/material.dart';
import './btc_converter.dart'; // Update this path according to your folder structure

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: BtcConverter(),
    );
  }
}
