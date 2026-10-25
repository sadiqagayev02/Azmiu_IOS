import 'dart:async';
import 'package:flutter/material.dart';
import 'package:azmiu_app/core/theme/app_text_styles.dart';

class GreetingSection extends StatefulWidget {
  final String studentName;

  const GreetingSection({super.key, required this.studentName});

  @override
  State<GreetingSection> createState() => _GreetingSectionState();
}

class _GreetingSectionState extends State<GreetingSection> {
  String _displayText = '';
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    final fullText = 'Salam, ${widget.studentName}';
    _currentIndex = 0;
    _displayText = '';
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_currentIndex < fullText.length) {
        setState(() {
          _currentIndex++;
          _displayText = fullText.substring(0, _currentIndex);
        });
      } else {
        timer.cancel();
        // Yazı bitdikdən sonra 3 saniyə gözlə və yenidən başlat
        Timer(const Duration(seconds: 3), () {
          if (mounted) _startTyping();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _displayText,
                style: AppTextStyles.greeting,
              ),
              const SizedBox(width: 8),
              // 👋 emoji (yazı bitdikdən sonra görünür)
              if (_displayText.length > 5)
                const Text('👋', style: TextStyle(fontSize: 28)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Şəxsi kabinetinizə xoş gəlmişsiniz!',
            style: AppTextStyles.greetingSubtitle,
          ),
        ],
      ),
    );
  }
}