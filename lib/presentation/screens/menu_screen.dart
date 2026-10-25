import 'package:flutter/material.dart';
import 'package:azmiu_app/core/app_routes.dart';
import 'package:azmiu_app/core/theme/app_colors.dart';
import 'package:azmiu_app/core/theme/app_text_styles.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Bütün keçidlərin siyahısı (11 yeni + əvvəlki 2)
    final menuItems = [
      // Əsas
      _MenuItem('Dərs cədvəli', Icons.calendar_month_rounded, AppRoutes.schedule),
      _MenuItem('Aylıq nəticələr', Icons.description_rounded, AppRoutes.grades),
      
      // Yeni 11
      _MenuItem('Tədris planı', Icons.menu_book_rounded, AppRoutes.curriculum),
      _MenuItem('Elektron jurnal', Icons.assignment_rounded, AppRoutes.journal),
      _MenuItem('Elektron materiallar', Icons.folder_copy_rounded, AppRoutes.materials),
      _MenuItem('İmtahan sualları', Icons.help_center_rounded, AppRoutes.examQuestions),
      _MenuItem('Onlayn dərslər', Icons.video_library_rounded, AppRoutes.onlineLessons),
      _MenuItem('İmtahan cədvəli', Icons.event_note_rounded, AppRoutes.examSchedule),
      _MenuItem('Yekun bal', Icons.analytics_rounded, AppRoutes.finalGrades),
      _MenuItem('Onlayn apellyasiya', Icons.gavel_rounded, AppRoutes.appeal),
      _MenuItem('LMS', Icons.computer_rounded, AppRoutes.lms),
      _MenuItem('Faydalı linklər', Icons.link_rounded, AppRoutes.usefulLinks),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Menyu'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Bütün bölmələr', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 16),
          
          ...menuItems.map((item) => _buildMenuItem(context, item)),
          
          const SizedBox(height: 30),
          const Center(
            child: Text(
              'AZMİU Tələbə Tətbiqi v1.0',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, _MenuItem item) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, item.route),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
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
              child: Icon(item.icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                item.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final String title;
  final IconData icon;
  final String route;
  _MenuItem(this.title, this.icon, this.route);
}