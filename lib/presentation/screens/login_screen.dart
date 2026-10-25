import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:azmiu_app/core/app_routes.dart';
import 'package:azmiu_app/core/constants.dart';
import 'package:azmiu_app/core/theme/app_colors.dart';
import 'package:azmiu_app/data/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  WebViewController? _controller;
  final AuthService _auth = AuthService();

  bool _isLoading = true;
  bool _savingCookies = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      _isLoading = false;
      return;
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setUserAgent(AppConstants.userAgent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() => _isLoading = true);
          },
          onPageFinished: (url) async {
            if (!mounted) return;
            setState(() => _isLoading = false);
            await _checkLogin(url);
          },
        ),
      )
      ..loadRequest(Uri.parse(AppConstants.loginUrl));
  }

  Future<void> _checkLogin(String url) async {
    if (_finished || _controller == null) return;

    debugPrint('=== URL: $url ===');

    final isLoginPage = url.contains('/giris') ||
        url.contains('/login') ||
        url == 'https://kabinet.azmiu.edu.az/' ||
        url == 'https://kabinet.azmiu.edu.az';

    final isDashboard = url.contains('/index') ||
        url.contains('/telebe/') ||
        url.contains('/istifadechi/profil');

    if (isLoginPage || !isDashboard) return;

    _finished = true;
    if (!mounted) return;
    setState(() => _savingCookies = true);

    debugPrint('=== LOGIN UĞURLU! COOKIE GÖTÜRÜLÜR... ===');

    bool success = false;
    for (int i = 0; i < 5; i++) {
      success = await _auth.extractAndSaveCookies(_controller!);
      debugPrint('=== COOKIE CƏHD $i: $success ===');
      if (success) break;
      await Future.delayed(const Duration(milliseconds: 800));
    }

    if (!mounted) return;

    if (success) {
      debugPrint('=== COOKIE-LƏR SAXLANDI! HOME-A KEÇİR ===');
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } else {
      debugPrint('=== COOKIE ALINMADI ===');
      _finished = false;
      setState(() => _savingCookies = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cookie-lər alınmadı. Yenidən cəhd edin.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'AZMİU Kabinetə Giriş',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: kIsWeb ? _buildWebPlaceholder() : _buildWebView(),
    );
  }

  Widget _buildWebPlaceholder() {
    return const Center(
      child: Text('WebView yalnız mobil cihazlarda işləyir.'),
    );
  }

  Widget _buildWebView() {
    if (_controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        WebViewWidget(controller: _controller!),
        if (_isLoading)
          const LinearProgressIndicator(
            backgroundColor: Colors.transparent,
            color: AppColors.primary,
          ),
        if (_savingCookies)
          Container(
            color: Colors.black54,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Daxil olunur...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}