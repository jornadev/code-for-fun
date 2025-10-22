// lib/screens/trail_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:code_for_fun/model/trail_model.dart';
import 'package:code_for_fun/model/lesson_model.dart';
import 'package:code_for_fun/screens/lesson_screen.dart';
import 'package:code_for_fun/constants/app_colors.dart';

// Constante para o raio do nó da lição, usado para cálculos no painter
const double _kNodeRadius = 35.0;

class TrailScreen extends StatefulWidget {
  final Trail trail;

  const TrailScreen({super.key, required this.trail});

  @override
  State<TrailScreen> createState() => _TrailScreenState();
}

class _TrailScreenState extends State<TrailScreen> with TickerProviderStateMixin {
  late final AnimationController _pathAnimationController;
  late final AnimationController _pulseAnimationController;
  int _currentLessonIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentLessonIndex = widget.trail.lessons.indexWhere((l) => !l.isCompleted);
    if (_currentLessonIndex == -1) {
      _currentLessonIndex = widget.trail.lessons.length - 1;
    }

    _pathAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _pulseAnimationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
        lowerBound: 0.95,
        upperBound: 1.05
    )..repeat(reverse: true);

    _pathAnimationController.forward();
  }

  @override
  void dispose() {
    _pathAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: Text(
          widget.trail.title,
          style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryPurple,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: AnimatedBuilder(
        animation: _pathAnimationController,
        builder: (context, child) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
                  child: CustomPaint(
                    painter: _TrailPathPainter(
                      progress: _pathAnimationController.value,
                      lessonCount: widget.trail.lessons.length,
                    ),
                    child: Column(
                      children: List.generate(widget.trail.lessons.length, (index) {
                        final animationProgress = _pathAnimationController.value;
                        final lessonVisibilityStart = (index / widget.trail.lessons.length) * 0.8;
                        final isVisible = animationProgress >= lessonVisibilityStart;

                        return AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: isVisible ? 1.0 : 0.0,
                          child: _LessonNode(
                            lesson: widget.trail.lessons[index],
                            isCurrent: index == _currentLessonIndex,
                            isLocked: index > _currentLessonIndex,
                            alignment: index.isEven ? Alignment.centerLeft : Alignment.centerRight,
                            pulseController: _pulseAnimationController,
                            pathController: _pathAnimationController,
                            visibilityStart: lessonVisibilityStart,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LessonNode extends StatelessWidget {
  final Lesson lesson;
  final bool isCurrent;
  final bool isLocked;
  final Alignment alignment;
  final AnimationController pulseController;
  final AnimationController pathController;
  final double visibilityStart;


  const _LessonNode({
    required this.lesson,
    required this.isCurrent,
    required this.isLocked,
    required this.alignment,
    required this.pulseController,
    required this.pathController,
    required this.visibilityStart,
  });

  IconData get _icon {
    if (isLocked) return Icons.lock_rounded;
    if (lesson.isCompleted) return Icons.check_circle_rounded;
    return Icons.star_rounded; // Lição atual
  }

  Color get _color {
    if (isLocked) return Colors.grey.shade400;
    if (lesson.isCompleted) return Colors.green.shade400;
    return AppColors.secondaryPurple; // Lição atual
  }

  void _onTap(BuildContext context) {
    if (isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Complete as lições anteriores para desbloquear!'),
        backgroundColor: AppColors.red,
      ));
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => LessonScreen(lesson: lesson)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLeftAligned = alignment == Alignment.centerLeft;

    final iconWidget = GestureDetector(
      onTap: () => _onTap(context),
      child: Container(
        width: _kNodeRadius * 2,
        height: _kNodeRadius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.lightGray,
          boxShadow: [
            BoxShadow(color: AppColors.black.withOpacity(0.1), blurRadius: 8, spreadRadius: 2),
          ],
        ),
        child: Icon(_icon, color: _color, size: 36),
      ),
    );

    final textWidget = SizedBox(
      width: MediaQuery.of(context).size.width * 0.4,
      child: Text(
        lesson.title,
        textAlign: isLeftAligned ? TextAlign.left : TextAlign.right,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isLocked ? Colors.grey.shade600 : AppColors.textDark,
          fontSize: 16,
        ),
      ),
    );

    final nodeContent = isCurrent
        ? ScaleTransition(scale: pulseController, child: iconWidget)
        : iconWidget;

    return Container(
      height: 150, // Espaço vertical para cada nó
      alignment: alignment,
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: pathController,
          curve: Interval(
            visibilityStart,
            (visibilityStart + 0.2).clamp(0.0, 1.0),
            curve: Curves.elasticOut,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: isLeftAligned
              ? [nodeContent, const SizedBox(width: 16), textWidget]
              : [textWidget, const SizedBox(width: 16), nodeContent],
        ),
      ),
    );
  }
}

class _TrailPathPainter extends CustomPainter {
  final double progress;
  final int lessonCount;
  final double nodeHeight = 150.0;

  _TrailPathPainter({required this.progress, required this.lessonCount});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryPurple.withOpacity(0.5)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (lessonCount < 2) return;

    for (int i = 0; i < lessonCount - 1; i++) {
      // Ponto de início do segmento
      double startX = size.width / 2 + (i.isEven ? -30 : 30);
      double startY = i * nodeHeight + (nodeHeight / 2);

      // Ponto final do segmento
      double endX = size.width / 2 + ((i + 1).isEven ? -30 : 30);
      double endY = (i + 1) * nodeHeight + (nodeHeight / 2);

      // Calcula o vetor e a distância para ajustar o início/fim da linha
      Offset startPoint = Offset(startX, startY);
      Offset endPoint = Offset(endX, endY);
      final distance = (endPoint - startPoint).distance;
      final direction = (endPoint - startPoint) / distance;

      // Encurta a linha para não passar por dentro do círculo
      final adjustedStartPoint = startPoint + direction * _kNodeRadius;
      final adjustedEndPoint = endPoint - direction * _kNodeRadius;

      // Ponto de controle para a curva
      final controlX = size.width / 2;
      final controlY = (startY + endY) / 2;

      path.moveTo(adjustedStartPoint.dx, adjustedStartPoint.dy);
      path.quadraticBezierTo(controlX, controlY, adjustedEndPoint.dx, adjustedEndPoint.dy);
    }

    // Anima o desenho do caminho
    final PathMetrics pathMetrics = path.computeMetrics(forceClosed: false);
    for (final PathMetric pathMetric in pathMetrics) {
      final Path extractPath = pathMetric.extractPath(
        0.0,
        pathMetric.length * progress,
      );
      canvas.drawPath(extractPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TrailPathPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}