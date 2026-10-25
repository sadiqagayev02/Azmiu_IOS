import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:azmiu_app/core/theme/app_colors.dart';
import 'package:azmiu_app/core/theme/app_text_styles.dart';
import 'package:azmiu_app/data/models/student_model.dart';

class FlipCardWidget extends StatefulWidget {
  final StudentModel student;
  final String? profileImageBase64;

  const FlipCardWidget({
    super.key,
    required this.student,
    this.profileImageBase64,
  });

  @override
  State<FlipCardWidget> createState() => _FlipCardWidgetState();
}

class _FlipCardWidgetState extends State<FlipCardWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _rotation = Tween<double>(begin: 0, end: math.pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _controller.addListener(() {
      // 90 dərəcədən sonra arxa tərəfə keç
      final isFrontNow = _controller.value < 0.5;
      if (isFrontNow != _isFront) {
        setState(() => _isFront = isFrontNow);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    HapticFeedback.mediumImpact();
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _rotation,
        builder: (context, child) {
          final angle = _rotation.value;
          final isBack = angle > math.pi / 2;

          // 3D fırlanma üçün transform
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001) // Perspektiv
            ..rotateY(angle);

          return Transform(
            alignment: Alignment.center,
            transform: transform,
            child: isBack
                ? Transform(
                    // Arxa tərəfi düzgün göstərmək üçün təkrar fırladırıq
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _buildBackSide(),
                  )
                : _buildFrontSide(),
          );
        },
      ),
    );
  }

  // ==========================================
  // ÖN TƏRƏF (Tələbə Kartı)
  // ==========================================
  Widget _buildFrontSide() {
    return Container(
      width: double.infinity,
      height: 230,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1C3557), Color(0xFF4A90E2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.account_balance, color: Colors.white, size: 30),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'AKTİV',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              // Profil şəkli
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                child: ClipOval(
                  child: widget.profileImageBase64 != null
                      ? Image.memory(base64Decode(widget.profileImageBase64!), fit: BoxFit.cover)
                      : const Icon(Icons.person, color: Colors.white, size: 30),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.student.displayFullName,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.student.specialty.isNotEmpty ? widget.student.specialty : 'İxtisas',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCardInfo('Tələbə №', widget.student.studentId.isNotEmpty ? widget.student.studentId : '---'),
              _buildCardInfo('Qrup', widget.student.group.isNotEmpty ? widget.student.group : '---'),
              _buildCardInfo('Tədris ili', widget.student.academicYear.isNotEmpty ? widget.student.academicYear : '---'),
            ],
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              '👆 Toxunaraq çevir',
              style: TextStyle(color: Colors.white54, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ARXA TƏRƏF (Virtual Kart / NFC)
  // ==========================================
  Widget _buildBackSide() {
    return Container(
      width: double.infinity,
      height: 230,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF7B68EE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.nfc, color: Colors.white, size: 60),
          ),
          const SizedBox(height: 16),
          const Text(
            'Virtual Tələbə Kartı',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Turniketə yaxınlaşdırın',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '👆 Toxunaraq geri qayıt',
              style: TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}