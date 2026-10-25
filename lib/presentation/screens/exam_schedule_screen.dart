import 'package:flutter/material.dart';
import 'package:azmiu_app/core/theme/app_colors.dart';
import 'package:azmiu_app/data/models/general_models.dart';
import 'package:azmiu_app/data/parsers/general_parsers.dart';
import 'package:azmiu_app/data/services/api_client.dart';

class ExamScheduleScreen extends StatefulWidget {
  const ExamScheduleScreen({super.key});
  @override
  State<ExamScheduleScreen> createState() => _ExamScheduleScreenState();
}

class _ExamScheduleScreenState extends State<ExamScheduleScreen> {
  final ApiClient _api = ApiClient();
  ExamScheduleModel? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      await _api.loadCookiesFromStorage();
      final html = await _api.fetchHtml('/telebe/examNewTeamTable');
      _data = GeneralParsers.parseExamSchedule(html);
      setState(() => _loading = false);
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('İmtahan cədvəli'), actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
      ]),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _data == null || _data!.exams.isEmpty
                  ? const Center(child: Text('Cədvəl boşdur'))
                  : ListView(
                      padding: const EdgeInsets.all(20),
                      children: _data!.exams.map((e) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.subject, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            const SizedBox(height: 6),
                            Text('${e.date} | ${e.time} | ${e.room}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      )).toList(),
                    ),
    );
  }
}