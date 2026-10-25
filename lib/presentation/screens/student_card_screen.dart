import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:azmiu_app/core/theme/app_colors.dart';
import 'package:azmiu_app/data/models/student_model.dart';
import 'package:azmiu_app/data/services/storage_service.dart';
import 'package:azmiu_app/presentation/screens/student_info_screen.dart';

class StudentCardScreen extends StatefulWidget {
  const StudentCardScreen({super.key});

  @override
  State<StudentCardScreen> createState() => _StudentCardScreenState();
}

class _StudentCardScreenState extends State<StudentCardScreen> {
  final StorageService _storage = StorageService();
  StudentModel? _student;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final student = await _storage.getStudent();
    if (!mounted) return;
    setState(() {
      _student = student;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_student == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Tələbə Kartım'), backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: Text('Tələbə məlumatları tapılmadı')),
      );
    }

    return StudentInfoScreen(
      initialStudent: _student,
    );
  }
}