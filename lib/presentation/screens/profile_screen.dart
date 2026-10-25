import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:azmiu_app/core/theme/app_colors.dart';
import 'package:azmiu_app/core/theme/app_text_styles.dart';
import 'package:azmiu_app/data/models/student_model.dart';
import 'package:azmiu_app/data/services/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final StorageService _storage = StorageService();
  final ImagePicker _picker = ImagePicker();

  StudentModel? _student;
  String? _profileImageBase64;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final student = await _storage.getStudent();
    final imageBase64 = await _storage.getProfileImage();

    if (!mounted) return;
    setState(() {
      _student = student;
      _profileImageBase64 = imageBase64;
      _loading = false;
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );

    if (image != null) {
      final bytes = await image.readAsBytes();
      final base64String = base64Encode(bytes);
      await _storage.saveProfileImage(base64String);

      if (!mounted) return;
      setState(() => _profileImageBase64 = base64String);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil şəkli yeniləndi')),
      );
    }
  }

  Future<void> _removeImage() async {
    await _storage.clearProfileImage();
    if (!mounted) return;
    setState(() => _profileImageBase64 = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Şəxsi Məlumatlar'),
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
                      // Profil şəkli
                      Center(
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.primary, width: 3),
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary.withValues(alpha: 0.2),
                                      AppColors.accent.withValues(alpha: 0.2),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: ClipOval(
                                  child: _profileImageBase64 != null
                                      ? Image.memory(
                                          base64Decode(_profileImageBase64!),
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(Icons.person, size: 60, color: AppColors.primary),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_profileImageBase64 != null)
                        TextButton.icon(
                          onPressed: _removeImage,
                          icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                          label: const Text('Şəkli sil', style: TextStyle(color: Colors.red)),
                        ),
                      const SizedBox(height: 24),
                      // Məlumat kartları
                      _buildInfoCard(Icons.badge_outlined, 'Tələbə №', _student!.studentId),
                      _buildInfoCard(Icons.person_outline, 'Ad Soyad', _student!.displayFullName),
                      _buildInfoCard(Icons.school_outlined, 'Fakültə', _student!.faculty),
                      _buildInfoCard(Icons.menu_book_outlined, 'İxtisas', _student!.specialty),
                      _buildInfoCard(Icons.groups_outlined, 'Qrup', _student!.group),
                      _buildInfoCard(Icons.school_rounded, 'Təhsil səviyyəsi', _student!.educationLevel),
                      _buildInfoCard(Icons.calendar_today_outlined, 'Tədris ili', _student!.academicYear),
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
                  value.isNotEmpty ? value : '---',
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