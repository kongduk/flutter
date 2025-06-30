import 'package:record/record.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

class NoteAnalysisResult {
  final String note;
  final double accuracy;

  NoteAnalysisResult({required this.note, required this.accuracy});
}

class Note {
  bool _isListening = false;
  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<Uint8List>? _subscription;
  Function(double)? onPitchDetected;

  final Map<String, double> _noteFrequencies = {
    'E2': 82.41,
    'A2': 110.00,
    'D3': 146.83,
    'G3': 196.00,
    'B3': 246.94,
    'E4': 329.63,
  };

  List<double> _freqHistory = [];
  static const int _freqHistoryLength = 5;

  Future<void> startListening() async {
    if (_isListening) return;
    _isListening = true;
    if (await _recorder.hasPermission()) {
      final stream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          numChannels: 1,
          sampleRate: 44100,
        ),
      );
      _subscription = stream.listen((buffer) {
        final floatData = _convertToFloat32(buffer);
        final freqResult = _detectFrequencyWithCorrelation(floatData, 44100);
        if (freqResult != null) {
          final freq = freqResult[0];
          final bestCorrelation = freqResult[1];
          if (bestCorrelation > 30 && freq > 50 && freq < 1000) {
            _freqHistory.add(freq);
            if (_freqHistory.length > _freqHistoryLength) {
              _freqHistory.removeAt(0);
            }
            final avgFreq =
                _freqHistory.reduce((a, b) => a + b) / _freqHistory.length;
            if (onPitchDetected != null) {
              onPitchDetected!(avgFreq);
            }
          } else {
          }
        }
      });
    }
  }

  Future<void> stopListening() async {
    if (!_isListening) return;
    await _subscription?.cancel();
    await _recorder.stop();
    _isListening = false;
  }

  Float32List _convertToFloat32(Uint8List bytes) {
    final buffer = Int16List.view(bytes.buffer);
    return Float32List.fromList(buffer.map((e) => e / 32768.0).toList());
  }

  /// autocorrelation + bestCorrelation 반환
  List<double>? _detectFrequencyWithCorrelation(
    Float32List buffer,
    int sampleRate,
  ) {
    if (buffer.length > 4096) {
      buffer = buffer.sublist(0, 4096);
    }
    int size = buffer.length;
    double rms = 0;
    for (int i = 0; i < size; i++) {
      rms += buffer[i] * buffer[i];
    }
    rms = math.sqrt(rms / size);
    print('RMS: $rms, buffer length: $size');
    if (rms < 0.01) return null;

    int maxSamples = (size / 2).floor();
    double bestCorrelation = 0;
    int bestOffset = -1;
    List<double> correlations = List.filled(maxSamples, 0);
    for (int offset = 1; offset < maxSamples; offset++) {
      double correlation = 0;
      for (int i = 0; i < maxSamples; i++) {
        correlation += buffer[i] * buffer[i + offset];
      }
      correlations[offset] = correlation;
      if (correlation > bestCorrelation) {
        bestCorrelation = correlation;
        bestOffset = offset;
      }
    }
    print('bestCorrelation: $bestCorrelation, bestOffset: $bestOffset');
    if (bestOffset > 0) {
      double freq = sampleRate / bestOffset;
      return [freq, bestCorrelation];
    }
    return null;
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
    _recorder.dispose();
  }
}
