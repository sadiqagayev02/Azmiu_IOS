import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:azmiu_app/core/constants.dart';
import 'package:azmiu_app/data/models/student_model.dart';

class StorageService {
  static const _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // ============================================
  // TƏLƏBƏ MƏLUMATLARI (SharedPreferences)
  // ============================================
  Future<StudentModel?> getStudent() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppConstants.studentKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return StudentModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveStudent(StudentModel student) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.studentKey,
      jsonEncode(student.toJson()),
    );
  }

  Future<void> clearStudent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.studentKey);
  }

  // ============================================
  // COOKIE-LƏR (SecureStorage)
  // ============================================
  Future<void> saveCookies({
    required String cfClearance,
    required String phpSession,
  }) async {
    await _secure.write(
      key: AppConstants.cookieCfClearanceKey,
      value: cfClearance,
    );
    await _secure.write(
      key: AppConstants.cookiePhpSessionKey,
      value: phpSession,
    );
    await _secure.write(
      key: AppConstants.cookieSavedAtKey,
      value: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  Future<Map<String, String>?> getCookies() async {
    final cf = await _secure.read(key: AppConstants.cookieCfClearanceKey);
    final php = await _secure.read(key: AppConstants.cookiePhpSessionKey);
    if (cf == null || php == null || cf.isEmpty || php.isEmpty) return null;
    return {
      AppConstants.cookieCfClearanceKey: cf,
      AppConstants.cookiePhpSessionKey: php,
    };
  }

  Future<bool> hasValidCookies() async {
    final savedAt = await _secure.read(key: AppConstants.cookieSavedAtKey);
    if (savedAt == null) return false;
    final saved = int.tryParse(savedAt) ?? 0;
    if (saved == 0) return false;
    final diff = DateTime.now().millisecondsSinceEpoch - saved;
    return diff < AppConstants.cookieMaxAge.inMilliseconds;
  }

  Future<void> clearCookies() async {
    await _secure.delete(key: AppConstants.cookieCfClearanceKey);
    await _secure.delete(key: AppConstants.cookiePhpSessionKey);
    await _secure.delete(key: AppConstants.cookieSavedAtKey);
  }

  Future<void> clearAll() async {
    await clearStudent();
    await clearCookies();
  }

  // ============================================
  // PROFİL ŞƏKLİ (Base64)
  // ============================================
  static const String _keyProfileImage = 'profile_image_base64';

  Future<void> saveProfileImage(String base64String) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProfileImage, base64String);
  }

  Future<String?> getProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyProfileImage);
  }

  Future<void> clearProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyProfileImage);
  }


    // ============================================
  // PIN KOD (4 rəqəmli)
  // ============================================
  static const String _keyPinCode = 'app_pin_code';
  static const String _keyBiometricEnabled = 'biometric_enabled';

  Future<void> savePinCode(String pin) async {
    await _secure.write(key: _keyPinCode, value: pin);
  }

  Future<String?> getPinCode() async {
    return await _secure.read(key: _keyPinCode);
  }

  Future<void> clearPinCode() async {
    await _secure.delete(key: _keyPinCode);
  }

  // ============================================
  // BİOMETRİK
  // ============================================
  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBiometricEnabled, enabled);
  }

  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyBiometricEnabled) ?? false;
  }
}


