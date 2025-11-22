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
  final List<String> lessonIds;

  const Trail({
    required this.id,
    required this.title,
    required this.icon,
    required this.level,
    required this.progress,
    required this.iconColor,
    this.lessons = const [],
    this.lessonIds = const [],
  });

  factory Trail.fromMap(Map<String, dynamic> map, String documentId) {
    return Trail(
      id: documentId,
      title: map['title'] ?? '',
      level: map['level'] ?? 'Iniciante',
      progress: (map['progress'] ?? 0).toDouble(),
      icon: IconData(
        map['iconCodePoint'] ?? 0xe156,
        fontFamily: map['iconFontFamily'] ?? 'MaterialIcons',
      ),
      iconColor: Color(map['colorValue'] ?? 0xFF000000),
      lessons: [],
      lessonIds: List<String>.from(map['lessonIds'] ?? []),
    );
  }
}