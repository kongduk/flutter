import 'package:flutter/material.dart';
import 'pages/tuner.dart';

void main() {
  runApp(const GuitarTunerApp());
}

class GuitarTunerApp extends StatelessWidget {
  const GuitarTunerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '기타 튜너',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const TunerPage(),
    );
  }
} 