import 'package:flutter/material.dart';
import 'package:azmiu_app/core/app_routes.dart';
import 'package:azmiu_app/core/theme/app_colors.dart';
import 'package:azmiu_app/core/theme/app_text_styles.dart';
import 'package:azmiu_app/data/models/schedule_model.dart';
import 'package:azmiu_app/data/repositories/azmiu_repository.dart';
import 'package:azmiu_app/data/services/api_client.dart'; // SessionExpiredException üçün

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final AzmiuRepository _repo = AzmiuRepository();
  ScheduleModel? _schedule;
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
      final schedule = await _repo.fetchSchedule();
      if (!mounted) return;
      setState(() {
        _schedule = schedule;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      // ƏGƏR SESSİYA BİTİBSƏ, LOGİN EKRANINA YÖNLƏNDİR
      if (e is SessionExpiredException || e.toString().contains('Sessiya')) {
        Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
        return;
      }

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
        title: const Text('Dərs cədvəli'),
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
                  'Cədvəli yükləmək mümkün olmadı',
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

    final schedule = _schedule;
    if (schedule == null || schedule.days.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text(
                'Cədvəl boşdur',
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
              const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  schedule.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Günlər
        ...schedule.days.map((day) => _buildDayCard(day)),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildDayCard(DayScheduleModel day) {
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
          // Gün adı
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  day.dayName,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${day.lessons.length} dərs',
                style: AppTextStyles.label,
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Dərslər
          ...day.lessons.map((lesson) => _buildLessonTile(lesson)),
        ],
      ),
    );
  }

  Widget _buildLessonTile(LessonModel lesson) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vaxt
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    lesson.time.split('-').first.trim(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    lesson.time.split('-').last.trim(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            
            // Dərs adı və tipi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.subject,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (lesson.type.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _typeColor(lesson.type).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        lesson.type,
                        style: TextStyle(
                          fontSize: 11,
                          color: _typeColor(lesson.type),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'Mühazirə':
        return Colors.blue;
      case 'Laboratoriya':
        return Colors.green;
      case 'Məşğələ':
        return Colors.orange;
      case 'Seminar':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}