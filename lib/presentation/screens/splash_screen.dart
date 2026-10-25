import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:azmiu_app/core/app_routes.dart';
import 'package:azmiu_app/core/theme/app_colors.dart';
import 'package:azmiu_app/data/services/auth_service.dart';
import 'package:azmiu_app/data/services/storage_service.dart';
import 'package:azmiu_app/core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

    Future<void> _initialize() async {
    await Future.delayed(const Duration(milliseconds: 800));

    final prefs = await SharedPreferences.getInstance();
    final hasSeenDemo = prefs.getBool('has_seen_demo_message') ?? false;

    if (!hasSeenDemo) {
      await _showDemoDialog();
      await prefs.setBool('has_seen_demo_message', true);
    }

    if (!mounted) return;

    final isLoggedIn = await _auth.isLoggedIn();
    if (!mounted) return;

    // Əgər login olubsa, PIN yoxlamasına keç
    if (isLoggedIn) {
      final storage = StorageService();
      final pin = await storage.getPinCode();
      final biometric = await storage.isBiometricEnabled();

      if (pin != null && pin.isNotEmpty) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.authLock);
      } else if (biometric) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.authLock);
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  Future<void> _showDemoDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Xoş Gəldiniz!'),
          ],
        ),
        content: const Text(
          'Bu tətbiq AZMİU Nəqliyyat fakültəsinin 416A2 qrup tələbəsi Sadiq tərəfindən yaradılmışdır.\n\n'
          'Qeyd: Tətbiq demo versiyasıdır.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anladım', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF7B68EE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: const Icon(Icons.school_rounded, color: Colors.white, size: 50),
            ),
            const SizedBox(height: 24),
            const Text('AZMİU Kabinet', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Demo Versiya', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}