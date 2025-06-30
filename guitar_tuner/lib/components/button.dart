import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Button extends StatelessWidget {
  final bool isListening;
  final VoidCallback onStart;
  final VoidCallback onStop;

  const Button({
    super.key,
    required this.isListening,
    required this.onStart,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isListening ? onStop : onStart,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 40,
          vertical: 20,
        ),
        backgroundColor: isListening ? Colors.red : Colors.blue,
        shape: const CircleBorder(),
        minimumSize: const Size(80, 80),
      ),
      child: isListening 
        ? const Icon(
            Icons.stop,
            size: 40,
            color: Colors.white,
          )
        : SvgPicture.asset(
            "assets/Mic.svg",
            height: 40,
            width: 40,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
    );
  }
} 