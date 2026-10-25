class StudentModel {
  final String fullName;
  final String faculty;
  final String studentId;
  final String group;
  final String specialty;
  final String educationLevel;
  final String academicYear;
  final String? avatarUrl;

  const StudentModel({
    required this.fullName,
    this.faculty = '',
    required this.studentId,
    required this.group,
    required this.specialty,
    required this.educationLevel,
    required this.academicYear,
    this.avatarUrl,
  });

  factory StudentModel.mock() => const StudentModel(
        fullName: 'AĞAYEV SADİQ BAKİR',
        faculty: 'Nəqliyyat',
        studentId: '2024/10123',
        group: '3C',
        specialty: 'Nəqliyyat mühəndisliyi',
        educationLevel: 'Bakalavr',
        academicYear: '2025 / 2026',
        avatarUrl: null,
      );

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
        fullName: (json['fullName'] ?? '').toString(),
        faculty: (json['faculty'] ?? '').toString(),
        studentId: (json['studentId'] ?? '').toString(),
        group: (json['group'] ?? '').toString(),
        specialty: (json['specialty'] ?? '').toString(),
        educationLevel: (json['educationLevel'] ?? '').toString(),
        academicYear: (json['academicYear'] ?? '').toString(),
        avatarUrl: json['avatarUrl']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'faculty': faculty,
        'studentId': studentId,
        'group': group,
        'specialty': specialty,
        'educationLevel': educationLevel,
        'academicYear': academicYear,
        'avatarUrl': avatarUrl,
      };

  String get displayFullName {
    if (fullName.isEmpty) return 'Tələbə';
    final parts = fullName.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${_capitalize(parts[0])} ${_capitalize(parts[1])}';
    }
    return _capitalize(parts.first);
  }

  String get displayName {
    final parts = fullName.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return 'Tələbə';
    return parts.length > 1 ? _capitalize(parts[1]) : _capitalize(parts.first);
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    final lower = s.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }
}