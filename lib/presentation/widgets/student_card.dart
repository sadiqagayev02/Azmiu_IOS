import 'package:flutter/material.dart';
import 'package:azmiu_app/core/theme/app_colors.dart';
import 'package:azmiu_app/core/theme/app_text_styles.dart';
import 'package:azmiu_app/data/models/student_model.dart';
import 'glass_container.dart';

class StudentCard extends StatelessWidget {
  final StudentModel student;
  final VoidCallback? onTap;

  const StudentCard({
    super.key,
    required this.student,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: onTap,
        child: GlassContainer(
          padding: const EdgeInsets.all(16),
          borderRadius: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Yuxarı hissə: Profil, Ad, İxtisas
              Row(
                children: [
                  // Profil şəkli
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade200, Colors.blue.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: ClipOval(
                      child: student.avatarUrl != null && student.avatarUrl!.isNotEmpty
                          ? Image.network(
                              student.avatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 30, color: Colors.white),
                            )
                          : const Icon(Icons.person, size: 30, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Ad və İxtisas
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.displayFullName,
                          style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.school_outlined, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                student.specialty.isNotEmpty ? student.specialty : 'İxtisas',
                                style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Orta hissə: 3 sütun
              Row(
                children: [
                  Expanded(
                    child: _buildInfoColumn('Tələbə №', student.studentId.isNotEmpty ? student.studentId : '---'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoColumn('Qrup', student.group.isNotEmpty ? student.group : '---'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoColumn('Təhsil səviyyəsi', student.educationLevel.isNotEmpty ? student.educationLevel : '---'),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Alt hissə: Tədris ili və AZMİU
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.calendar_today, size: 14, color: AppColors.primary),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tədris ili', style: AppTextStyles.label.copyWith(fontSize: 10)),
                              Text(
                                student.academicYear.isNotEmpty ? student.academicYear : '2025 / 2026',
                                style: AppTextStyles.value.copyWith(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      const Icon(Icons.account_balance, size: 16, color: Color(0xFF1C3557)),
                      const SizedBox(width: 4),
                      Text(
                        'AZMİU',
                        style: AppTextStyles.sectionTitle.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1C3557),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label.copyWith(fontSize: 10)),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.value.copyWith(fontSize: 13),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}