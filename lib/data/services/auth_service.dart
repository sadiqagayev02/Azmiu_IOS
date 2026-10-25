import 'package:flutter/foundation.dart' show debugPrint;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:azmiu_app/core/constants.dart';
import 'package:azmiu_app/data/services/storage_service.dart';

class AuthService {
  final StorageService _storage = StorageService();

  Future<bool> extractAndSaveCookies(WebViewController controller) async {
    try {
      String? cfClearance;
      String? phpSession;

      // Yalnız JavaScript ilə cookie-ləri oxu (WebViewCookieManager istifadə etmədən)
      final result = await controller.runJavaScriptReturningResult('document.cookie');
      final cookieStr = result.toString().replaceAll('"', '');
      debugPrint('=== JS COOKIE: $cookieStr ===');

      for (final part in cookieStr.split(';')) {
        final trimmed = part.trim();
        if (trimmed.startsWith('${AppConstants.cookieCfClearanceKey}=')) {
          cfClearance = trimmed.substring(AppConstants.cookieCfClearanceKey.length + 1);
        } else if (trimmed.startsWith('${AppConstants.cookiePhpSessionKey}=')) {
          phpSession = trimmed.substring(AppConstants.cookiePhpSessionKey.length + 1);
        }
      }

      if (cfClearance != null && phpSession != null) {
        await _storage.saveCookies(cfClearance: cfClearance, phpSession: phpSession);
        debugPrint('=== COOKIE-LƏR SAXLANDI! ===');
        return true;
      }

      if (phpSession != null && cfClearance == null) {
        debugPrint('=== YALNIZ PHPSESSID TAPILDI, ONU SAXLAYIRAM ===');
        await _storage.saveCookies(cfClearance: 'N/A', phpSession: phpSession);
        return true;
      }

      debugPrint('=== COOKIE TAPILMADI ===');
      return false;
    } catch (e) {
      debugPrint('=== COOKIE XƏTA: $e ===');
      return false;
    }
  }

  Future<bool> isLoggedIn() async => await _storage.hasValidCookies();
  Future<void> logout() async => await _storage.clearCookies();
}