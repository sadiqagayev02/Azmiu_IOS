import 'package:flutter/material.dart';
import 'package:azmiu_app/core/theme/app_colors.dart';
import 'package:azmiu_app/core/theme/app_text_styles.dart';
import 'package:azmiu_app/data/models/general_models.dart';
import 'package:azmiu_app/data/parsers/general_parsers.dart';
import 'package:azmiu_app/data/services/api_client.dart';

class ExamQuestionsScreen extends StatefulWidget {
  const ExamQuestionsScreen({super.key});
  @override
  State<ExamQuestionsScreen> createState() => _ExamQuestionsScreenState();
}

class _ExamQuestionsScreenState extends State<ExamQuestionsScreen> {
  final ApiClient _api = ApiClient();
  ExamQuestionsModel? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      await _api.loadCookiesFromStorage();
      final html = await _api.fetchHtml('/telebe/imtahan_suallar');
      _data = GeneralParsers.parseExamQuestions(html);
      setState(() => _loading = false);
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('İmtahan sualları'), actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
      ]),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _data == null || _data!.questions.isEmpty
                  ? const Center(child: Text('Suallar yoxdur'))
                  : ListView(
                      padding: const EdgeInsets.all(20),
                      children: _data!.questions.map((q) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(q.subject, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            const SizedBox(height: 6),
                            Text(q.topic, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      )).toList(),
                    ),
    );
  }
}