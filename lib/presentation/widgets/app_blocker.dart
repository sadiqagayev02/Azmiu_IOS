import 'dart:async';
import 'package:flutter/material.dart';
import 'package:azmiu_app/core/theme/app_colors.dart';
import 'package:azmiu_app/data/services/developer_status_service.dart';

class AppBlocker extends StatefulWidget {
  final Widget child;
  const AppBlocker({super.key, required this.child});

  @override
  State<AppBlocker> createState() => _AppBlockerState();
}

class _AppBlockerState extends State<AppBlocker> {
  final DeveloperStatusService _statusService = DeveloperStatusService();
  bool _isBlocked = false;
  String _blockMessage = '';
  Timer? _timer;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    // İlk yoxlama
    _checkStatus();
    
    // Hər 5 saniyədən bir avtomatik yoxla (real-time effekt üçün)
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkStatus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    if (_isChecking) return; // Əgər artıq yoxlanırsa, təkrar başlatma
    _isChecking = true;

    try {
      final status = await _statusService.checkAppStatus();
      
      if (!mounted) return;

      final bool newIsBlocked = !(status['is_active'] as bool);
      final String newMessage = status['message'] as String;

      // Əgər vəziyyət dəyişibsə, ekranı yenilə
      if (newIsBlocked != _isBlocked) {
        setState(() {
          _isBlocked = newIsBlocked;
          _blockMessage = newMessage;
        });
      }
    } finally {
      _isChecking = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isBlocked) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_outline, size: 80, color: Colors.redAccent),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Tətbiq Müvəqqəti Bağlanmışdır',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  _blockMessage,
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () async {
                    // Dərhal yoxla
                    await _checkStatus();
                    
                    // Əgər hələ də bloklanıbsa, mesaj göstər
                    if (mounted && _isBlocked) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tətbiq hələ də bağlıdır. Zəhmət olmasa gözləyin.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Yenidən yoxla'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Avtomatik yenilənmə hər 5 saniyədə bir baş verir.',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}