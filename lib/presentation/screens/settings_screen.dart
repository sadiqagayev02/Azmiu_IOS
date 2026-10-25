import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:azmiu_app/core/theme/app_colors.dart';
import 'package:azmiu_app/core/theme/app_text_styles.dart';
import 'package:azmiu_app/data/services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storage = StorageService();
  final LocalAuthentication _localAuth = LocalAuthentication();

  bool _biometricEnabled = false;
  bool _hasPinCode = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final pin = await _storage.getPinCode();
    final biometric = await _storage.isBiometricEnabled();

    if (!mounted) return;
    setState(() {
      _hasPinCode = pin != null && pin.isNotEmpty;
      _biometricEnabled = biometric;
      _loading = false;
    });
  }

  Future<void> _setPinCode() async {
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _PinCodeDialog(),
    );

    if (result != null && result.length == 4) {
      await _storage.savePinCode(result);
      if (!mounted) return;
      setState(() => _hasPinCode = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN kod təyin edildi')),
      );
    }
  }

  Future<void> _removePinCode() async {
    await _storage.clearPinCode();
    if (!mounted) return;
    setState(() => _hasPinCode = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PIN kod silindi')),
    );
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      try {
        final canCheck = await _localAuth.canCheckBiometrics;
        final isSupported = await _localAuth.isDeviceSupported();

        if (!canCheck || !isSupported) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bu cihazda biometrik dəstəklənmir')),
          );
          return;
        }

        final authenticated = await _localAuth.authenticate(
          localizedReason: 'Barmaq izi ilə təsdiqləyin',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );

        if (!authenticated) return;
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xəta: $e')),
        );
        return;
      }
    }

    await _storage.setBiometricEnabled(value);
    if (!mounted) return;
    setState(() => _biometricEnabled = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tənzimləmələr'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // ==========================================
                // TƏHLÜKƏSİZLİK
                // ==========================================
                Text('Təhlükəsizlik', style: AppTextStyles.sectionTitle),
                const SizedBox(height: 12),

                // PIN kod
                _buildSettingCard(
                  icon: Icons.pin_outlined,
                  title: 'PIN kod',
                  subtitle: _hasPinCode ? 'PIN kod təyin edilib' : 'PIN kod təyin edilməyib',
                  trailing: _hasPinCode
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: AppColors.primary),
                              onPressed: _setPinCode,
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: _removePinCode,
                            ),
                          ],
                        )
                      : ElevatedButton(
                          onPressed: _setPinCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Təyin et'),
                        ),
                ),

                const SizedBox(height: 12),

                // Barmaq izi
                _buildSettingCard(
                  icon: Icons.fingerprint,
                  title: 'Barmaq izi',
                  subtitle: _biometricEnabled
                      ? 'Barmaq izi aktivdir'
                      : 'Barmaq izi deaktivdir',
                  trailing: Switch(
                    value: _biometricEnabled,
                    activeColor: AppColors.primary,
                    onChanged: _toggleBiometric,
                  ),
                ),

                const SizedBox(height: 24),

                // ==========================================
                // HAQQINDA
                // ==========================================
                Text('Haqqında', style: AppTextStyles.sectionTitle),
                const SizedBox(height: 12),

                _buildSettingCard(
                  icon: Icons.info_outline,
                  title: 'Tətbiq versiyası',
                  subtitle: '1.0.0',
                  trailing: const SizedBox.shrink(),
                ),

                const SizedBox(height: 12),

                _buildSettingCard(
                  icon: Icons.person_outline,
                  title: 'Tərtibatçı',
                  subtitle: 'Sadiq Ağayev',
                  trailing: const SizedBox.shrink(),
                ),

                const SizedBox(height: 12),

                _buildSettingCard(
                  icon: Icons.school_outlined,
                  title: 'Universitet',
                  subtitle: 'AZMİU',
                  trailing: const SizedBox.shrink(),
                ),

                const SizedBox(height: 40),
              ],
            ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.value.copyWith(fontSize: 15)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.label.copyWith(fontSize: 12)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

// ============================================
// PIN KOD DİALOQU
// ============================================
class _PinCodeDialog extends StatefulWidget {
  const _PinCodeDialog();

  @override
  State<_PinCodeDialog> createState() => _PinCodeDialogState();
}

class _PinCodeDialogState extends State<_PinCodeDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final pin = _controller.text.trim();
    if (pin.length != 4) {
      setState(() => _error = 'PIN kod 4 rəqəm olmalıdır');
      return;
    }
    if (int.tryParse(pin) == null) {
      setState(() => _error = 'Yalnız rəqəmlər daxil edin');
      return;
    }
    Navigator.of(context).pop(pin);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('PIN kod təyin et'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '4 rəqəmli PIN kod daxil edin',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            maxLength: 4,
            obscureText: true,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, letterSpacing: 12, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              counterText: '',
              hintText: '••••',
              errorText: _error,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (_) => setState(() => _error = null),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Ləğv et'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Yadda saxla'),
        ),
      ],
    );
  }
}