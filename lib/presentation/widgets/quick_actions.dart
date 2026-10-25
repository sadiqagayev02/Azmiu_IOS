import 'package:flutter/material.dart';
import 'package:azmiu_app/core/app_routes.dart';
import 'package:azmiu_app/core/theme/app_colors.dart';
import 'package:azmiu_app/core/theme/app_text_styles.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        title: 'Dərs cədvəli',
        icon: Icons.calendar_month_rounded,
        iconColor: AppColors.actionBlueIcon,
        bgColor: AppColors.actionBlueBg,
        route: AppRoutes.schedule,
      ),
      _QuickAction(
        title: 'Qiymətlər',
        icon: Icons.description_rounded,
        iconColor: AppColors.actionTealIcon,
        bgColor: AppColors.actionTealBg,
        route: AppRoutes.grades,
      ),
      _QuickAction(
        title: 'Tələbə kartım',
        icon: Icons.badge_rounded,
        iconColor: AppColors.actionPurpleIcon,
        bgColor: AppColors.actionPurpleBg,
        route: AppRoutes.studentCard,
      ),
      _QuickAction(
        title: 'Xidmətlər',
        icon: Icons.school_rounded,
        iconColor: AppColors.actionPinkIcon,
        bgColor: AppColors.actionPinkBg,
        route: AppRoutes.services,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: actions.map((action) => _buildActionItem(context, action)).toList(),
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, _QuickAction action) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, action.route),
      child: Container(
        width: 82, // Genişliyi ekrana görə tənzimləyə bilərsən
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.55),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: action.bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                action.icon,
                color: action.iconColor,
                size: 22,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    action.title,
                    style: AppTextStyles.actionLabel.copyWith(fontSize: 11),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 10,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String route;

  _QuickAction({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.route,
  });
}