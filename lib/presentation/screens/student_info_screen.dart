import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:azmiu_app/core/theme/app_colors.dart';
import 'package:azmiu_app/core/theme/app_text_styles.dart';
import 'package:azmiu_app/data/models/student_model.dart';
import 'package:azmiu_app/data/services/storage_service.dart';
import 'package:azmiu_app/presentation/widgets/flip_card_widget.dart'; // Növbəti addımda yaradılacaq

class StudentInfoScreen extends StatefulWidget {
  final StudentModel? initialStudent;

  const StudentInfoScreen({super.key, this.initialStudent});

  @override
  State<StudentInfoScreen> createState() => _StudentInfoScreenState();
}

class _StudentInfoScreenState extends State<StudentInfoScreen> {
  final StorageService _storage = StorageService();
  StudentModel? _student;
  String? _profileImageBase64;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final student = widget.initialStudent ?? await _storage.getStudent();
    final imageBase64 = await _storage.getProfileImage();

    if (!mounted) return;
    setState(() {
      _student = student;
      _profileImageBase64 = imageBase64;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tələbə Məlumatları'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _student == null
              ? const Center(child: Text('Tələbə məlumatları tapılmadı'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // ==========================================
                      // 1. FLIP KART (NFC funksionallığı ilə)
                      // ==========================================
                      FlipCardWidget(
                        student: _student!,
                        profileImageBase64: _profileImageBase64,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // ==========================================
                      // 2. TƏLƏBƏ MƏLUMATLARI (Geniş)
                      // ==========================================
                      Text('Ətraflı Məlumatlar', style: AppTextStyles.sectionTitle),
                      const SizedBox(height: 12),
                      
                      _buildInfoCard(Icons.badge_outlined, 'Tələbə №', _student!.studentId.isNotEmpty ? _student!.studentId : '---'),
                      _buildInfoCard(Icons.person_outline, 'Ad Soyad', _student!.displayFullName),
                      _buildInfoCard(Icons.school_outlined, 'Fakültə', _student!.faculty.isNotEmpty ? _student!.faculty : '---'),
                      _buildInfoCard(Icons.menu_book_outlined, 'İxtisas', _student!.specialty.isNotEmpty ? _student!.specialty : '---'),
                      _buildInfoCard(Icons.groups_outlined, 'Qrup', _student!.group.isNotEmpty ? _student!.group : '---'),
                      _buildInfoCard(Icons.school_rounded, 'Təhsil səviyyəsi', _student!.educationLevel.isNotEmpty ? _student!.educationLevel : '---'),
                      _buildInfoCard(Icons.calendar_today_outlined, 'Tədris ili', _student!.academicYear.isNotEmpty ? _student!.academicYear : '---'),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.label.copyWith(fontSize: 11)),
                const SizedBox(height: 2),
                Text(
                  value, 
                  style: AppTextStyles.value.copyWith(fontSize: 15),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}