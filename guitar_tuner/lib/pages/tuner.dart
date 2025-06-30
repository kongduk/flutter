import 'package:flutter/material.dart';
import '../components/setting.dart';
import '../components/button.dart';
import '../components/note.dart';
import 'intro.dart';

// StatefulWidget 사용
class TunerPage extends StatefulWidget {
  const TunerPage({super.key});

  @override
  State<TunerPage> createState() => _TunerPageState();
}

class _TunerPageState extends State<TunerPage> {
  final Note _noteService = Note();
  bool _isListening = false;
  String _currentNote = '대기 중...';
  double _currentFrequency = 0.0;
  double _tuningAccuracy = 0.0;
  
  bool _showIntro = true;

  @override
  void initState() {
    super.initState();
    _noteService.onPitchDetected = _updatePitch;
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

    final result = _noteService.analyzeNote(frequency);
    
    setState(() {
      _currentNote = result.note;
      _currentFrequency = frequency;
      _tuningAccuracy = result.accuracy;
    });
  }

  void _startListening() async {
    try {
      await _noteService.startListening();
      setState(() {
        _isListening = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('시작 실패: $e')),
      );
    }
  }

  void _stopListening() async {
    try {
      await _noteService.stopListening();
      setState(() {
        _isListening = false;
        _currentNote = '대기 중...';
        _currentFrequency = 0.0;
        _tuningAccuracy = 0.0;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('중지 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _showIntro
        ? IntroPage(
            onStart: () {
              setState(() {
                _showIntro = false;
              });
            },
          )
        : Scaffold(
            appBar: AppBar(
              title: const Text('기타 튜너'),
              centerTitle: true,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Setting(
                    currentNote: _currentNote,
                    currentFrequency: _currentFrequency,
                    tuningAccuracy: _tuningAccuracy,
                  ),
                  const SizedBox(height: 40),
                  Button(
                    isListening: _isListening,
                    onStart: _startListening,
                    onStop: _stopListening,
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