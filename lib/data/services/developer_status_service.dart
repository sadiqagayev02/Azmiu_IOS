import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class DeveloperStatusService {
  // Sənin GitHub linkin
  static const String _statusUrl =
      'https://raw.githubusercontent.com/sadiqagayev02/azmiu-app-status/main/status.json';

  Future<Map<String, dynamic>> checkAppStatus() async {
    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 5);
      dio.options.receiveTimeout = const Duration(seconds: 5);

      // Keşi (cache) keçmək üçün xüsusi başlıqlar
      final response = await dio.get(
        _statusUrl,
        options: Options(
          headers: {
            'Cache-Control': 'no-cache',
            'Pragma': 'no-cache',
          },
        ),
      );

      // Əgər cavab 200-dürsə, JSON-u yoxla
      if (response.statusCode == 200) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        // ⚠️ ƏN VACİB MƏQAM: Yalnız tam olaraq false olduqda bağla
        // Əgər is_active yoxdursa və ya səhvdirsə -> tətbiq AÇIQ qalır
        final bool isActive = data['is_active'] != false;

        final String message = data['message'] ??
            'Tətbiq tərtibatçı tərəfindən müvəqqəti bağlanmışdır.';

        debugPrint('=== STATUS YOXLANDI: isActive = $isActive ===');
        return {'is_active': isActive, 'message': message};
      }

      // Əgər 200 deyilsə (404, 500 və s.) -> tətbiq AÇIQ qalır
      debugPrint('=== STATUS: HTTP ${response.statusCode} (tətbiq açıq qalır) ===');
      return {'is_active': true, 'message': ''};
    } on DioException catch (e) {
      // İnternet, DNS, timeout xətası -> tətbiq AÇIQ qalır
      debugPrint('=== STATUS: İnternet xətası (tətbiq açıq qalır) ${e.type} ===');
      return {'is_active': true, 'message': ''};
    } catch (e) {
      // JSON parse xətası və ya başqa gözlənilməz xəta -> AÇIQ qalır
      debugPrint('=== STATUS: Gözlənilməz xəta (tətbiq açıq qalır) $e ===');
      return {'is_active': true, 'message': ''};
    }
  }
}