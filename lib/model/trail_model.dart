import 'package:flutter/material.dart';
import 'package:code_for_fun/model/lesson_model.dart';

class Trail {
  final String id;
  final String title;
  final IconData icon;
  final String level;
  final double progress;
  final Color iconColor;
  final List<Lesson> lessons;

  const Trail({
    required this.id,
    required this.title,
    required this.icon,
    required this.level,
    required this.progress,
    required this.iconColor,
    required this.lessons,
  });
}