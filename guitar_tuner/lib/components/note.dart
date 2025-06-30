import 'dart:async';
import 'dart:html' as html;
import 'dart:math' as math;

class NoteAnalysisResult {
  final String note;
  final double accuracy;

  NoteAnalysisResult({required this.note, required this.accuracy});
}

class Note {
  bool _isListening = false;
  StreamSubscription<html.MessageEvent>? _jsListener;
  Function(double)? onPitchDetected;

  final Map<String, double> _noteFrequencies = {
    'E2': 82.41,
    'A2': 110.00,
    'D3': 146.83,
    'G3': 196.00,
    'B3': 246.94,
    'E4': 329.63,
  };

  void _setupJavascriptChannel() {
    _jsListener = html.window.onMessage.listen((event) {
      if (event.data is Map) {
        final data = event.data as Map;
        if (data['type'] == 'pitch') {
          final frequency = data['frequency'] as double;
          onPitchDetected?.call(frequency);
        }
      }
    });
  }

  Future<void> startListening() async {
    if (_isListening) return;

    _setupJavascriptChannel();
    html.window.postMessage({'type': 'startListening'}, '*');
    _isListening = true;
  }

  Future<void> stopListening() async {
    if (!_isListening) return;

    html.window.postMessage({'type': 'stopListening'}, '*');
    await _jsListener?.cancel();
    _isListening = false;
  }

  NoteAnalysisResult analyzeNote(double frequency) {
    if (frequency == 0 || frequency < 60 || frequency > 400) {
      return NoteAnalysisResult(note: '대기 중...', accuracy: 0.0);
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
      return NoteAnalysisResult(note: '대기 중...', accuracy: 0.0);
    }

    return NoteAnalysisResult(
      note: closestNote,
      accuracy: accuracy.clamp(0.0, 1.0),
    );
  }

  bool get isListening => _isListening;

  void dispose() {
    stopListening();
  }
} 