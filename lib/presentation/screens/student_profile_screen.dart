import 'package:flutter/material.dart';
import 'package:azmiu_app/data/models/student_model.dart';
import 'package:azmiu_app/presentation/screens/student_info_screen.dart';

class StudentProfileScreen extends StatelessWidget {
  final StudentModel? initialStudent;
  final String? nfcUid;

  const StudentProfileScreen({
    super.key,
    this.initialStudent,
    this.nfcUid,
  });

  @override
  Widget build(BuildContext context) {
    // Köhnə ekran əvəzinə yeni StudentInfoScreen-ə yönləndiririk
    return StudentInfoScreen(
      initialStudent: initialStudent,
    );
  }
}