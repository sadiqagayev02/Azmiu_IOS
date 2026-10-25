import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class VirtualCardService {
  static const String _isCardActiveKey = 'is_virtual_card_active';
  static const String _lastScanTimeKey = 'last_nfc_scan_time';

  // ============================================
  // KARTIN AKTİV OLUB-OLMADIĞINI YOXLA
  // ============================================
  Future<bool> isCardActive() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isCardActiveKey) ?? false;
    } catch (e) {
      debugPrint('VirtualCardService isCardActive error: $e');
      return false;
    }
  }

  // ============================================
  // KARTI AKTİV ET
  // ============================================
  Future<void> activateCard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isCardActiveKey, true);
      debugPrint('Virtual kart aktivləşdirildi.');
    } catch (e) {
      debugPrint('VirtualCardService activateCard error: $e');
    }
  }

  // ============================================
  // KARTI DEAKTİV ET
  // ============================================
  Future<void> deactivateCard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isCardActiveKey, false);
      debugPrint('Virtual kart deaktiv edildi.');
    } catch (e) {
      debugPrint('VirtualCardService deactivateCard error: $e');
    }
  }

  // ============================================
  // SON SKAN VAXTINI YADDA SAXLA
  // ============================================
  Future<void> saveLastScanTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _lastScanTimeKey,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      debugPrint('VirtualCardService saveLastScanTime error: $e');
    }
  }

  // ============================================
  // SON SKAN VAXTINI OXU
  // ============================================
  Future<DateTime?> getLastScanTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeStr = prefs.getString(_lastScanTimeKey);
      if (timeStr == null) return null;
      return DateTime.tryParse(timeStr);
    } catch (e) {
      debugPrint('VirtualCardService getLastScanTime error: $e');
      return null;
    }
  }

  // ============================================
  // KART MƏLUMATLARINI SİL
  // ============================================
  Future<void> clearCardData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_isCardActiveKey);
      await prefs.remove(_lastScanTimeKey);
    } catch (e) {
      debugPrint('VirtualCardService clearCardData error: $e');
    }
  }
}