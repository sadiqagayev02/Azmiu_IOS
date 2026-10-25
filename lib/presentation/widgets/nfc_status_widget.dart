import 'package:flutter/material.dart';

enum NfcUiStatus { idle, scanning, success, error, unavailable }

/// NFC vəziyyətini göstərən kiçik widget: ikon, dalğa halqaları, başlıq və alt yazı.
class NfcStatusWidget extends StatefulWidget {
  const NfcStatusWidget({
    super.key,
    required this.status,
    required this.title,
    this.subtitle,
    this.size = 52,
  });

  final NfcUiStatus status;
  final String title;
  final String? subtitle;
  final double size;

  static const Color _primary = Color(0xFF2E5BFF);
  static const Color _success = Color(0xFF16A34A);
  static const Color _error = Color(0xFFDC2626);
  static const Color _warning = Color(0xFFF59E0B);

  static Color colorFor(NfcUiStatus status) {
    switch (status) {
      case NfcUiStatus.idle:
      case NfcUiStatus.scanning:
        return _primary;
      case NfcUiStatus.success:
        return _success;
      case NfcUiStatus.error:
        return _error;
      case NfcUiStatus.unavailable:
        return _warning;
    }
  }

  static IconData iconFor(NfcUiStatus status) {
    switch (status) {
      case NfcUiStatus.idle:
      case NfcUiStatus.scanning:
        return Icons.nfc_rounded;
      case NfcUiStatus.success:
        return Icons.check_rounded;
      case NfcUiStatus.error:
        return Icons.priority_high_rounded;
      case NfcUiStatus.unavailable:
        return Icons.block_rounded;
    }
  }

  @override
  State<NfcStatusWidget> createState() => _NfcStatusWidgetState();
}

class _NfcStatusWidgetState extends State<NfcStatusWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant NfcStatusWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    if (widget.status == NfcUiStatus.scanning) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _ring(double phase, double box, Color color) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final double t = (_controller.value + phase) % 1.0;
        final double diameter = widget.size + (box - widget.size) * t;
        return Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withValues(alpha: (1 - t) * 0.4),
              width: 2,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color color = NfcStatusWidget.colorFor(widget.status);
    final double box = widget.size * 1.55;
    final bool scanning = widget.status == NfcUiStatus.scanning;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: box,
          height: box,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              if (scanning) ...<Widget>[
                _ring(0.0, box, color),
                _ring(0.5, box, color),
              ],
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Container(
                  key: ValueKey<NfcUiStatus>(widget.status),
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        color.withValues(alpha: 0.20),
                        color.withValues(alpha: 0.08),
                      ],
                    ),
                    border: Border.all(
                      color: color.withValues(alpha: 0.40),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    NfcStatusWidget.iconFor(widget.status),
                    size: widget.size * 0.54,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: widget.status == NfcUiStatus.idle
                ? const Color(0xFF111827)
                : color,
          ),
        ),
        if (widget.subtitle != null) ...<Widget>[
          const SizedBox(height: 3),
          Text(
            widget.subtitle!,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              height: 1.3,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ],
    );
  }
}