import 'package:flutter/material.dart';

class QuickActionModel {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String route;

  const QuickActionModel({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.route,
  });
}