import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:math' as math;

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
      home: const TunerScreen(),
    );
  }
}

class TunerScreen extends StatefulWidget {
  const TunerScreen({super.key});

  @override
  State<TunerScreen> createState() => _TunerScreenState();
}

class _TunerScreenState extends State<TunerScreen> {
  bool _isListening = false;
  String _currentNote = '대기 중...';
  double _currentFrequency = 0.0;
  double _tuningAccuracy = 0.0;

  final Map<String, double> _noteFrequencies = {
    'E2': 82.41,
    'A2': 110.00,
    'D3': 146.83,
    'G3': 196.00,
    'B3': 246.94,
    'E4': 329.63,
  };

  @override
  void initState() {
    super.initState();
    _setupJavascriptChannel();
  }

  void _setupJavascriptChannel() {
    html.window.onMessage.listen((event) {
      if (event.data is Map) {
        final data = event.data as Map;
        if (data['type'] == 'pitch') {
          final frequency = data['frequency'] as double;
          _updatePitch(frequency);
        }
      }
    });
  }

  void _updatePitch(double frequency) {
    if (frequency == 0 || frequency < 60 || frequency > 400) {
      setState(() {
        _currentNote = '대기 중...';
        _currentFrequency = 0.0;
        _tuningAccuracy = 0.0;
      });
      return;
    }

    String closestNote = 'E2';
    double minDifference = double.infinity;

    _noteFrequencies.forEach((note, noteFreq) {
      final difference = (frequency - noteFreq).abs();
      if (difference < minDifference) {
        minDifference = difference;
        closestNote = note;
      }
    });

    final targetFrequency = _noteFrequencies[closestNote]!;
    final difference = frequency - targetFrequency;
    final accuracy = 1.0 - (difference.abs() / targetFrequency);

    if (accuracy < 0.3) {
      setState(() {
        _currentNote = '대기 중...';
        _currentFrequency = 0.0;
        _tuningAccuracy = 0.0;
      });
      return;
    }

    setState(() {
      _currentNote = closestNote;
      _currentFrequency = frequency;
      _tuningAccuracy = accuracy.clamp(0.0, 1.0);
    });
  }

  void _startListening() {
    html.window.postMessage({'type': 'startListening'}, '*');
    setState(() {
      _isListening = true;
    });
  }

  void _stopListening() {
    html.window.postMessage({'type': 'stopListening'}, '*');
    setState(() {
      _isListening = false;
      _currentNote = '대기 중...';
      _currentFrequency = 0.0;
      _tuningAccuracy = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('기타 튜너'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '현재 음표',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Text(
              _currentNote,
              style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              '${_currentFrequency.toStringAsFixed(1)} Hz',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: _tuningAccuracy,
              minHeight: 10,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _tuningAccuracy > 0.9
                    ? Colors.green
                    : _tuningAccuracy > 0.7
                        ? Colors.yellow
                        : Colors.red,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isListening ? _stopListening : _startListening,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                backgroundColor: _isListening ? Colors.red : Colors.blue,
              ),
              child: Text(
                _isListening ? '중지' : '시작',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_isListening) {
      _stopListening();
    }
    super.dispose();
  }
} 