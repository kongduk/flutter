import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// StatefulWidget 사용
class Web extends StatefulWidget {
  const Web({Key? key}) : super(key: key);

  @override
  State<Web> createState() => _WebTunerPageState();
}

class _WebTunerPageState extends State<Web> {
  double? _frequency;
  StreamSubscription<html.MessageEvent>? _jsListener;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _jsListener = html.window.onMessage.listen((event) {
        if (event.data is Map && event.data['type'] == 'pitch') {
          setState(() {
            _frequency = (event.data['frequency'] as num?)?.toDouble();
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _stopListening();
    _jsListener?.cancel();
    super.dispose();
  }

  void _startListening() {
    if (!_isListening && kIsWeb) {
      html.window.postMessage({'type': 'startListening'}, '*');
      setState(() {
        _isListening = true;
      });
    }
  }

  void _stopListening() {
    if (_isListening && kIsWeb) {
      html.window.postMessage({'type': 'stopListening'}, '*');
      setState(() {
        _isListening = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('웹 기타 튜너')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _frequency != null
                  ? '주파수: ${_frequency!.toStringAsFixed(2)} Hz'
                  : '마이크를 시작하세요',
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 32),
            _isListening
                ? ElevatedButton(
                    onPressed: _stopListening,
                    child: const Text('중지'),
                  )
                : ElevatedButton(
                    onPressed: _startListening,
                    child: const Text('마이크 시작'),
                  ),
          ],
        ),
      ),
    );
  }
} 