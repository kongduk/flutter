import 'package:flutter/material.dart';

class Setting extends StatelessWidget {
  final String currentNote;
  final double currentFrequency;
  final double tuningAccuracy;

  const Setting({
    super.key,
    required this.currentNote,
    required this.currentFrequency,
    required this.tuningAccuracy,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          '현재 음표',
          style: TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 20),
        Text(
          currentNote,
          style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          '${currentFrequency.toStringAsFixed(1)} Hz',
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 20),
        LinearProgressIndicator(
          value: tuningAccuracy,
          minHeight: 10,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            tuningAccuracy > 0.9
                ? Colors.green
                : tuningAccuracy > 0.7
                    ? Colors.yellow
                    : Colors.red,
          ),
        ),
      ],
    );
  }
} 