// lib/screens/trail_screen.dart
import 'package:flutter/material.dart';
import 'package:code_for_fun/model/trail_model.dart';
import 'package:code_for_fun/model/lesson_model.dart';
import 'package:code_for_fun/screens/lesson_screen.dart';

class TrailProgressView extends StatelessWidget {
  final List<Lesson> lessons;
  final Color trailColor;

  const TrailProgressView({
    super.key,
    required this.lessons,
    required this.trailColor,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, double>> positions = [
      {'top': 0, 'left': 150},
      {'top': 120, 'left': 50},
      {'top': 240, 'left': 180},
      {'top': 360, 'left': 80},
      {'top': 480, 'left': 200},
      {'top': 600, 'left': 100},
      {'top': 720, 'left': 220},
      {'top': 840, 'left': 60},
    ];

    final containerHeight = lessons.length > positions.length
        ? (lessons.length - 1) * 120.0 + 180.0
        : positions.last['top']! + 100;

    return SizedBox(
      height: containerHeight,
      child: Stack(
        children: [
          _buildConnectorLines(positions),
          ...lessons.asMap().entries.map((entry) {
            final index = entry.key;
            final lesson = entry.value;
            final position = positions[index];
            final bool isCompleted = lesson.isCompleted;

            return Positioned(
              top: position['top'],
              left: position['left'],
              child: _buildLessonPin(context, lesson, isCompleted),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildLessonPin(BuildContext context, Lesson lesson, bool isCompleted) {
    final isFirstLesson = lesson.id == 'l1';
    final isUnlocked = isCompleted || isFirstLesson;

    return GestureDetector(
      onTap: () {
        if (isUnlocked) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LessonScreen(lesson: lesson),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Esta lição está bloqueada. Complete a anterior primeiro!'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.location_pin,
            size: 60,
            color: isUnlocked ? trailColor : Colors.grey[400],
          ),
          Positioned(
            top: 10,
            child: Icon(
              isCompleted ? Icons.check : Icons.lock,
              size: 24,
              color: isCompleted ? Colors.white : Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectorLines(List<Map<String, double>> positions) {
    return CustomPaint(
      painter: ConnectorLinePainter(positions, Colors.grey[400]!),
      size: Size(double.infinity, positions.last['top']! + 100),
    );
  }
}

class ConnectorLinePainter extends CustomPainter {
  final List<Map<String, double>> positions;
  final Color color;

  ConnectorLinePainter(this.positions, this.color);

  @override
  void paint(Canvas canvas, Size size) {
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class TrailScreen extends StatelessWidget {
  final Trail trail;

  const TrailScreen({super.key, required this.trail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(trail.title),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Iniciante em programação',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TrailProgressView(
              lessons: trail.lessons,
              trailColor: trail.iconColor,
            ),
          ],
        ),
      ),
    );
  }
}