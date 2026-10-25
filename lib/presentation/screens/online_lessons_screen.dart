import 'package:flutter/material.dart';
import 'package:azmiu_app/core/theme/app_colors.dart';
import 'package:azmiu_app/data/models/general_models.dart';
import 'package:azmiu_app/data/parsers/general_parsers.dart';
import 'package:azmiu_app/data/services/api_client.dart';

class OnlineLessonsScreen extends StatefulWidget {
  const OnlineLessonsScreen({super.key});
  @override
  State<OnlineLessonsScreen> createState() => _OnlineLessonsScreenState();
}

class _OnlineLessonsScreenState extends State<OnlineLessonsScreen> {
  final ApiClient _api = ApiClient();
  OnlineLessonsModel? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      await _api.loadCookiesFromStorage();
      final html = await _api.fetchHtml('/telebe/lms');
      _data = GeneralParsers.parseOnlineLessons(html);
      setState(() => _loading = false);
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Onlayn dərslər'), actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
      ]),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _data == null || _data!.lessons.isEmpty
                  ? const Center(child: Text('Dərslər yoxdur'))
                  : ListView(
                      padding: const EdgeInsets.all(20),
                      children: _data!.lessons.map((l) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.video_library, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Expanded(child: Text(l.subject, style: const TextStyle(fontSize: 14))),
                          ],
                        ),
                      )).toList(),
                    ),
    );
  }
}