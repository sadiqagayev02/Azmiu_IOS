import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class FileDownloadService {
  final Dio _dio = Dio();

  FileDownloadService() {
    // SSL sertifikatını keç (Universitetin sertifikatı köhnədir)
    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );
  }

  Future<File?> downloadFile(
    String url, {
    required Function(double progress) onProgress,
  }) async {
    try {
      // 1. Yaddaş icazəsi istə (Android 10+ üçün lazım deyil, amma köhnələr üçün)
      if (Platform.isAndroid) {
        await Permission.storage.request();
      }

      // 2. Yükləmə qovluğunu tap
      Directory? dir;
      if (Platform.isAndroid) {
        // Android üçün "Downloads" qovluğuna yazmağa çalışaq
        dir = Directory('/storage/emulated/0/Download');
        if (!await dir.exists()) {
          // Əgər yoxdursa, tətbiqin öz yaddaşına yaz
          dir = await getExternalStorageDirectory();
        }
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      if (dir == null) {
        throw Exception('Yükləmə qovluğu tapılmadı');
      }

      // 3. Faylın adını URL-dən çıxar
      final fileName = url.split('/').last;
      final filePath = '${dir.path}/$fileName';

      debugPrint('=== YÜKLƏNİR: $url ===');
      debugPrint('=== FAYL: $filePath ===');

      // 4. Faylı yüklə
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received / total);
          }
        },
      );

      final file = File(filePath);
      if (await file.exists()) {
        debugPrint('=== YÜKLƏMƏ TAMAMLANDI: ${file.path} ===');
        return file;
      }
      return null;
    } on DioException catch (e) {
      debugPrint('=== DIO XƏTA: $e ===');
      throw Exception('Faylı yükləmək mümkün olmadı: ${e.message}');
    } catch (e) {
      debugPrint('=== XƏTA: $e ===');
      throw Exception('Xəta: $e');
    }
  }
}