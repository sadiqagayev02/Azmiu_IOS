import 'package:flutter/material.dart';
import 'package:azmiu_app/core/theme/app_colors.dart';
import 'package:azmiu_app/core/theme/app_text_styles.dart';
import 'package:azmiu_app/data/models/grades_model.dart';
import 'package:azmiu_app/data/repositories/azmiu_repository.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  final AzmiuRepository _repo = AzmiuRepository();
  GradesModel? _grades;
  bool _loading = true;
  String? _error;

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
      await _repo.init();
      final grades = await _repo.fetchGrades();
      if (!mounted) return;
      setState(() {
        _grades = grades;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Qiymətlər'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
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
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 40),
                const SizedBox(height: 12),
                const Text(
                  'Qiymətləri yükləmək mümkün olmadı',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _load,
                  child: const Text('Yenidən cəhd et'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final grades = _grades;
    if (grades == null || grades.subjects.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text(
                'Hələ ki qiymət yoxdur',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Başlıq
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.accent],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.description_rounded,
                  color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  grades.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Fənlər
        ...grades.subjects.map((subject) => _buildSubjectCard(subject)),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSubjectCard(SubjectGradeModel subject) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fənn adı
          Row(
            children: [
              Container(
                width: 4,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  subject.subjectName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Aylar
          ...subject.months.map((month) => _buildMonthRow(month)),
        ],
      ),
    );
  }

  Widget _buildMonthRow(GradeMonthModel month) {
    // Əgər bütün qiymətlər boşdursa, göstərmə
    final isEmpty = month.freeWorkCount.isEmpty &&
        month.seminar.isEmpty &&
        month.lab.isEmpty &&
        month.courseWork.isEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ay adı
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  month.monthName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              if (isEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  'qiymət yoxdur',
                  style: AppTextStyles.label.copyWith(fontSize: 11),
                ),
              ],
            ],
          ),
          
          if (!isEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (month.freeWorkCount.isNotEmpty)
                  _buildGradeChip('Sərbəst iş', month.freeWorkCount, Colors.blue),
                if (month.seminar.isNotEmpty)
                  _buildGradeChip('Seminar', month.seminar, Colors.orange),
                if (month.lab.isNotEmpty)
                  _buildGradeChip('Laboratoriya', month.lab, Colors.green),
                if (month.courseWork.isNotEmpty)
                  _buildGradeChip('Kurs işi', month.courseWork, Colors.purple),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGradeChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value.isEmpty ? '—' : value,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}