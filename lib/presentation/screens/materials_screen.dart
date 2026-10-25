import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:azmiu_app/core/theme/app_colors.dart';
import 'package:azmiu_app/core/theme/app_text_styles.dart';
import 'package:azmiu_app/data/models/materials_model.dart';
import 'package:azmiu_app/data/parsers/materials_parser.dart';
import 'package:azmiu_app/data/services/api_client.dart';
import 'package:azmiu_app/data/services/file_download_service.dart';

class MaterialsScreen extends StatefulWidget {
  const MaterialsScreen({super.key});

  @override
  State<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends State<MaterialsScreen> {
  final ApiClient _api = ApiClient();
  final FileDownloadService _downloader = FileDownloadService();
  MaterialsModel? _materials;
  bool _loading = true;
  String? _error;

  // Yükləmə vəziyyəti (URL -> Progress)
  final Map<String, double> _downloadProgress = {};
  final Map<String, String> _downloadedFiles = {}; // URL -> File Path

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _api.loadCookiesFromStorage();
      final html = await _api.fetchHtml('/telebe/elektron_materiallar');
      final materials = MaterialsParser.parse(html);

      if (!mounted) return;
      setState(() {
        _materials = materials;
        _loading = false;
      });
      
      // Yüklənmiş faylları yoxla
      _checkDownloadedFiles(materials.items);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _checkDownloadedFiles(List<MaterialItem> items) async {
    final dir = await getApplicationDocumentsDirectory();
    for (var item in items) {
      if (item.link.isNotEmpty) {
        final fileName = item.link.split('/').last;
        final file = File('${dir.path}/$fileName');
        if (await file.exists()) {
          _downloadedFiles[item.link] = file.path;
        }
      }
    }
    if (mounted) setState(() {});
  }

  String _getFullUrl(String link) {
    return link.startsWith('http') ? link : 'https://kabinet.azmiu.edu.az$link';
  }

  Future<void> _downloadFile(MaterialItem item) async {
    if (item.link.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link yoxdur')));
      return;
    }

    final fullUrl = _getFullUrl(item.link);
    setState(() => _downloadProgress[fullUrl] = 0);

    try {
      final file = await _downloader.downloadFile(
        fullUrl,
        onProgress: (progress) {
          if (mounted) setState(() => _downloadProgress[fullUrl] = progress);
        },
      );

      if (file != null && mounted) {
        setState(() {
          _downloadProgress.remove(fullUrl);
          _downloadedFiles[item.link] = file.path;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fayl yükləndi!')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _downloadProgress.remove(fullUrl));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xəta: $e')));
      }
    }
  }

  Future<void> _openFile(MaterialItem item) async {
    if (item.link.isEmpty) return;

    if (_downloadedFiles.containsKey(item.link)) {
      // Fayl artıq yüklənib, aç
      final result = await OpenFile.open(_downloadedFiles[item.link]);
      if (result.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Açmaq olmadı: ${result.message}')));
      }
    } else {
      // Yüklənməyibsə, yüklə
      await _downloadFile(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Elektron materiallar'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _load,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    if (_error != null) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 40),
                const SizedBox(height: 12),
                const Text('Materialları yükləmək mümkün olmadı', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(fontSize: 12, color: Colors.black54), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: _load, child: const Text('Yenidən cəhd et')),
              ],
            ),
          ),
        ],
      );
    }

    final materials = _materials;
    if (materials == null || materials.items.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: const [Center(child: Padding(padding: EdgeInsets.all(40), child: Text('Material yoxdur')))],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: Row(
            children: [
              const Icon(Icons.folder_copy_rounded, color: Colors.white, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(materials.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('Materiallar (${materials.items.length})', style: AppTextStyles.sectionTitle),
        const SizedBox(height: 4),
        const Text('Sağa sürüşdür: Yüklə • Sola sürüşdür: Aç • Üzərinə klik: Aç', style: TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 12),
        ...materials.items.map((item) => _buildSlidableCard(item)),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSlidableCard(MaterialItem item) {
    final fullUrl = _getFullUrl(item.link);
    final isDownloading = _downloadProgress.containsKey(fullUrl);
    final progress = _downloadProgress[fullUrl] ?? 0;
    final isDownloaded = _downloadedFiles.containsKey(item.link);

    return Slidable(
      key: ValueKey(item.number),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (context) => _downloadFile(item),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.download_rounded,
            label: 'Yüklə',
            borderRadius: BorderRadius.circular(16),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (context) => _openFile(item),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            icon: Icons.open_in_new_rounded,
            label: 'Aç',
            borderRadius: BorderRadius.circular(16),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => _openFile(item),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Center(child: Text(item.number, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.subject, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(item.topic, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                    if (isDownloading) ...[
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: progress, color: AppColors.primary),
                    ],
                  ],
                ),
              ),
              if (isDownloading)
                const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
              else if (isDownloaded)
                const Icon(Icons.check_circle, size: 22, color: Colors.green)
              else if (item.link.isNotEmpty)
                const Icon(Icons.download_rounded, size: 22, color: AppColors.primary)
              else
                const Icon(Icons.description_outlined, size: 22, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}