import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:azmiu_app/core/app_routes.dart';
import 'package:azmiu_app/core/theme/app_colors.dart';
import 'package:azmiu_app/data/services/storage_service.dart';

class AuthLockScreen extends StatefulWidget {
  const AuthLockScreen({super.key});

  @override
  State<AuthLockScreen> createState() => _AuthLockScreenState();
}

class _AuthLockScreenState extends State<AuthLockScreen> {
  final StorageService _storage = StorageService();
  final LocalAuthentication _localAuth = LocalAuthentication();

  final List<String> _enteredPin = [];
  String? _savedPin;
  bool _biometricEnabled = false;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAuthSettings();
  }

  Future<void> _loadAuthSettings() async {
    _savedPin = await _storage.getPinCode();
    _biometricEnabled = await _storage.isBiometricEnabled();

    if (!mounted) return;
    setState(() => _loading = false);

    // Əgər biometrik aktivdirsə, avtomatik cəhd et
    if (_biometricEnabled) {
      _authenticateBiometric();
    }
  }

  Future<void> _authenticateBiometric() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Tətbiqə daxil olmaq üçün barmaq izi ilə təsdiqləyin',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (authenticated && mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    } catch (e) {
      // Xəta olsa, PIN ekranı qalır
    }
  }

  void _onNumberTap(String number) {
    if (_enteredPin.length >= 4) return;

    setState(() {
      _enteredPin.add(number);
      _error = null;
    });

    if (_enteredPin.length == 4) {
      _checkPin();
    }
  }

  void _onBackspace() {
    if (_enteredPin.isEmpty) return;
    setState(() {
      _enteredPin.removeLast();
      _error = null;
    });
  }

  void _checkPin() {
    final entered = _enteredPin.join();
    if (entered == _savedPin) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } else {
      setState(() {
        _error = 'Yanlış PIN kod';
        _enteredPin.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            // Logo
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF7B68EE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(Icons.lock_outline, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 20),
            const Text(
              'PIN kodu daxil edin',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13))
            else
              const Text(
                'Tətbiqə giriş üçün 4 rəqəmli PIN kod',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            const SizedBox(height: 40),

            // PIN nöqtələri
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final isFilled = index < _enteredPin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled ? AppColors.primary : Colors.transparent,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                );
              }),
            ),
            const SizedBox(height: 40),

            // Rəqəmlər
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var row in [
                      ['1', '2', '3'],
                      ['4', '5', '6'],
                      ['7', '8', '9'],
                    ])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: row
                              .map((num) => _buildNumberButton(num))
                              .toList(),
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Biometrik düymə
                        if (_biometricEnabled)
                          GestureDetector(
                            onTap: _authenticateBiometric,
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.fingerprint, color: AppColors.primary, size: 32),
                            ),
                          )
                        else
                          const SizedBox(width: 70),
                        _buildNumberButton('0'),
                        // Sil düyməsi
                        GestureDetector(
                          onTap: _onBackspace,
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.backspace_outlined, color: Colors.red, size: 28),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return GestureDetector(
      onTap: () => _onNumberTap(number),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}