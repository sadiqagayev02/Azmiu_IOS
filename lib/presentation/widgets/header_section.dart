import 'package:flutter/material.dart';
import 'package:azmiu_app/core/theme/app_text_styles.dart';
import 'package:azmiu_app/core/theme/app_colors.dart';

class HeaderSection extends StatelessWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  const HeaderSection({
    super.key,
    this.onNotificationTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Sol: Loqo + Yazı
          Row(
            children: [
              Image.asset(
                'assets/images/azmiu_logo.png',
                width: 42,
                height: 42,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.account_balance,
                  size: 42,
                  color: Color(0xFF1C3557),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AZMİU',
                    style: AppTextStyles.sectionTitle.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1C3557),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Azərbaycan Memarlıq və\nİnşaat Universiteti',
                    style: AppTextStyles.label.copyWith(
                      fontSize: 10,
                      height: 1.3,
                      color: const Color(0xFF1C3557).withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Sağ: 3 düymə
          Row(
            children: [
              _buildIconButton(
                Icons.notifications_outlined,
                hasDot: true,
                onTap: onNotificationTap,
              ),
              const SizedBox(width: 8),
              _buildIconButton(Icons.person_outline_rounded, onTap: onProfileTap),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, {bool hasDot = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: const Color(0xFF1C3557), size: 20),
            if (hasDot)
              Positioned(
                top: 10,
                right: 11,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.notificationDot,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}