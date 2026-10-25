import 'package:flutter/material.dart';
import 'package:azmiu_app/core/theme/app_colors.dart';
import 'package:azmiu_app/data/models/general_models.dart';
import 'package:azmiu_app/data/parsers/general_parsers.dart';
import 'package:azmiu_app/data/services/api_client.dart';

class FinalGradesScreen extends StatefulWidget {
  const FinalGradesScreen({super.key});
  @override
  State<FinalGradesScreen> createState() => _FinalGradesScreenState();
}

class _FinalGradesScreenState extends State<FinalGradesScreen> {
  final ApiClient _api = ApiClient();
  FinalGradesModel? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      await _api.loadCookiesFromStorage();
      final html = await _api.fetchHtml('/telebe/yekun_bal');
      _data = GeneralParsers.parseFinalGrades(html);
      setState(() => _loading = false);
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Yekun bal'), actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
      ]),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _data == null || _data!.grades.isEmpty
                  ? const Center(child: Text('Nəticələr yoxdur'))
                  : ListView(
                      padding: const EdgeInsets.all(20),
                      children: _data!.grades.map((g) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(g.subject, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                              Text('Kredit: ${g.credits}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ])),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(g.grade, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      )).toList(),
                    ),
    );
  }
}