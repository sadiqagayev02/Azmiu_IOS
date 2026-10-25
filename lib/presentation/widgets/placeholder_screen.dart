import 'package:flutter/material.dart';
import 'package:azmiu_app/core/theme/app_colors.dart';
import 'package:azmiu_app/core/theme/app_text_styles.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title, style: AppTextStyles.sectionTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 80, color: AppColors.primary.withOpacity(0.5)),
            ),
            const SizedBox(height: 24),
            Text(
              'Tezliklə...',
              style: AppTextStyles.greeting.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              'Bu bölmə hazırlanır.',
              style: AppTextStyles.cardSubtitle,
            ),
          ],
        ),
      ),
    );
  }
}