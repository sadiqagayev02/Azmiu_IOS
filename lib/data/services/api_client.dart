import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

import 'package:azmiu_app/core/constants.dart';
import 'package:azmiu_app/data/services/storage_service.dart';

class ApiClient {
  late final Dio _dio;
  late final CookieJar _cookieJar;
  final StorageService _storage = StorageService();

  ApiClient() {
    _cookieJar = CookieJar();
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'User-Agent': AppConstants.userAgent,
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'az-AZ,az;q=0.9,en;q=0.8',
      },
      responseType: ResponseType.plain,
      followRedirects: true,
      validateStatus: (status) => status != null && status < 500,
    ));

    // SSL SERTİFİKAT XƏTASINI KEÇMƏK ÜÇÜN (Universitetin sertifikatı köhnəlib)
    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );

    if (!kIsWeb) {
      _dio.interceptors.add(CookieManager(_cookieJar));
    }
  }

  Dio get dio => _dio;

  Future<void> loadCookiesFromStorage() async {
    if (kIsWeb) return;

    final cookies = await _storage.getCookies();
    debugPrint('=== LOAD COOKIES: ${cookies != null} ===');
    if (cookies == null) return;

    final uri = Uri.parse(AppConstants.baseUrl);
    final cookieList = cookies.entries
        .map((e) => Cookie(e.key, e.value))
        .toList();

    await _cookieJar.saveFromResponse(uri, cookieList);
    debugPrint('=== COOKIE-LƏR DIO-YA YÜKLƏNDİ ===');
  }

  Future<String> fetchHtml(String path) async {
    debugPrint('=== FETCH BAŞLAYIR: $path ===');
    try {
      final response = await _dio.get<String>(path);
      final html = response.data ?? '';

      debugPrint('=== HTML STATUS: ${response.statusCode} ===');
      debugPrint('=== HTML UZUNLUĞU: ${html.length} ===');

      if (_isLoginPage(html)) {
        debugPrint('=== LOGIN SƏHİFƏSİ GÖRÜNDÜ (cookie bitib) ===');
        throw const SessionExpiredException();
      }
      return html;
    } catch (e) {
      debugPrint('=== FETCH XƏTA: $e ===');
      rethrow;
    }
  }

  bool _isLoginPage(String html) {
    if (html.isEmpty) return true;
    final hasLoginForm = html.contains('name="login"') ||
        html.contains('name="password"') ||
        html.contains('istifadechi/giris');
    final tooSmall = html.length < 5000;
    return hasLoginForm && tooSmall;
  }

  Future<void> logout() async {
    try {
      await _dio.get(AppConstants.logoutUrl);
    } catch (_) {}
    await _cookieJar.deleteAll();
    await _storage.clearCookies();
  }
}

class SessionExpiredException implements Exception {
  const SessionExpiredException();
  String get message => 'Sessiya bitib. Yenidən daxil olun.';
  @override
  String toString() => message;
}