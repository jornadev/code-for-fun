import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:code_for_fun/model/trail_model.dart';
import 'package:code_for_fun/model/lesson_model.dart';
import 'package:code_for_fun/constants/app_colors.dart';
import 'package:code_for_fun/service/user_service.dart';
import 'package:code_for_fun/service/trail_service.dart';

import 'lesson_screen.dart';

class TrailScreen extends StatefulWidget {
  final Trail trail;

  const TrailScreen({super.key, required this.trail});

  @override
  State<TrailScreen> createState() => _TrailScreenState();
}

class _TrailScreenState extends State<TrailScreen> {
  final UserService _userService = UserService();
  final TrailService _trailService = TrailService();

  final Color _mainPurple = const Color(0xFF673AB7);
  final Color _darkBackgroundGray = const Color(0xFF2B2B2B);

  Set<String> _completedLessonIds = {};
  bool _isLoadingUserData = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final completedList = await _userService.getCompletedLessons();
    if (mounted) {
      setState(() {
        _completedLessonIds = completedList.toSet();
        _isLoadingUserData = false;
      });
    }
  }

  void _navigateToLesson(BuildContext context, Lesson lesson) async {
    final bool? didCompleteModule = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => LessonScreen(lesson: lesson),
      ),
    );

    if (didCompleteModule == true) {
      _loadUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final listBgColor = isDark ? _darkBackgroundGray : Colors.white;

    return Scaffold(
      backgroundColor: _mainPurple,
      appBar: AppBar(
        backgroundColor: _mainPurple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.trail.title.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: listBgColor,
        child: _isLoadingUserData
            ? Center(child: CircularProgressIndicator(color: _mainPurple))
            : StreamBuilder<List<Lesson>>(
          stream: _trailService.getLessons(widget.trail.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: _mainPurple));
            }

            final lessons = snapshot.data ?? [];

            if (lessons.isEmpty) {
              return Center(
                child: Text(
                  'Em breve novas aulas!',
                  style: TextStyle(color: isDark ? Colors.white70 : Colors.grey[600]),
                ),
              );
            }

            int unlockedIndex = 0;
            for (int i = 0; i < lessons.length; i++) {
              if (!_completedLessonIds.contains(lessons[i].id)) {
                unlockedIndex = i;
                break;
              }
              if (i == lessons.length - 1) unlockedIndex = lessons.length;
            }

            final bool isTrailCompleted = unlockedIndex == lessons.length;

            return ListView.builder(
              padding: const EdgeInsets.only(top: 40, bottom: 100),
              itemCount: lessons.length + 1,
              itemBuilder: (context, index) {

                if (index < lessons.length) {
                  final lesson = lessons[index];

                  final bool isCompleted = _completedLessonIds.contains(lesson.id);
                  final bool isCurrent = (index == unlockedIndex);
                  final bool isLocked = index > unlockedIndex;

                  return _buildPathNode(
                    context,
                    index,
                    lessons.length,
                    lesson,
                    isCompleted,
                    isCurrent,
                    isLocked,
                    isDark,
                  );
                } else {
                  return _buildFinishLine(context, isTrailCompleted, isDark);
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildFinishLine(BuildContext context, bool isTrailCompleted, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 40),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isTrailCompleted ? _mainPurple : Colors.grey.shade400,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: isTrailCompleted ? Colors.amber.withOpacity(0.5) : Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                  Icons.workspace_premium_rounded,
                  color: isTrailCompleted ? Colors.white : Colors.grey.shade600,
                  size: 70
              ),
            ),

            const SizedBox(height: 24),

            Text(
              isTrailCompleted ? 'TRILHA CONCLUÍDA!' : 'LINHA DE CHEGADA',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: isTrailCompleted ? _mainPurple : (isDark ? Colors.white : AppColors.textDark),
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              isTrailCompleted
                  ? 'Parabéns! Você é um Mestre em ${widget.trail.title}.'
                  : 'Complete todos os módulos para conquistar este troféu!',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _cleanLessonTitle(String title) {
    final regex = RegExp(r'^Módulo\s+\d+:\s*');
    return title.replaceAll(regex, '').trim();
  }


  Widget _buildPathNode(
      BuildContext context,
      int index,
      int totalLength,
      Lesson lesson,
      bool isCompleted,
      bool isCurrent,
      bool isLocked,
      bool isDark,
      ) {
    final double xOffset = math.sin(index * 2.5) * 80.0;

    final lessonNumber = index + 1;

    Color circleColor;
    Color shadowColor;
    Color iconColor;
    double buttonSize = 75.0;

    if (isCompleted) {
      circleColor = Colors.amber;
      shadowColor = Colors.amber[800]!;
      iconColor = Colors.white;
    } else if (isCurrent) {
      circleColor = _mainPurple;
      shadowColor = const Color(0xFF4527A0);
      iconColor = Colors.white;
      buttonSize = 90.0;
    } else {
      circleColor = isDark ? const Color(0xFF424242) : Colors.grey[300]!;
      shadowColor = isDark ? Colors.black54 : Colors.grey[400]!;
      iconColor = isDark ? Colors.white30 : Colors.grey[500]!;
    }

    String? labelContent;
    IconData iconContent = Icons.lock;

    if (isLocked) {
      iconContent = Icons.lock;
    } else if (isCompleted) {
      iconContent = Icons.star_rounded;
    } else {
      labelContent = '$lessonNumber';
    }

    return Center(
      child: SizedBox(
        width: double.infinity,
        height: 150,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (index < totalLength)
              Transform.translate(
                offset: Offset(
                    (xOffset + (math.sin((index + 1) * 2.5) * 80.0)) / 2,
                    60
                ),
                child: Transform.rotate(
                  angle: -math.atan(
                      (math.sin((index + 1) * 2.5) * 80.0 - xOffset) / 100
                  ),
                  child: Container(
                    width: 10,
                    height: 90,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.amber.withOpacity(0.5)
                          : isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),

            Transform.translate(
              offset: Offset(xOffset, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _GameButton3D(
                    size: buttonSize,
                    color: circleColor,
                    shadowColor: shadowColor,
                    icon: iconContent,
                    iconColor: iconColor,
                    isLocked: isLocked,
                    label: labelContent,
                    onTap: isLocked
                        ? null
                        : () => _navigateToLesson(context, lesson),
                  ),

                ],
              ),
            ),

            if (index % 3 == 0 && index > 0)
              Transform.translate(
                offset: Offset(-xOffset * 1.8, -30),
                child: Icon(
                  Icons.star,
                  color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.withOpacity(0.15),
                  size: 40,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GameButton3D extends StatefulWidget {
  final double size;
  final Color color;
  final Color shadowColor;
  final IconData icon;
  final Color iconColor;
  final bool isLocked;
  final String? label;
  final VoidCallback? onTap;

  const _GameButton3D({
    required this.size,
    required this.color,
    required this.shadowColor,
    required this.icon,
    required this.iconColor,
    required this.isLocked,
    this.label,
    this.onTap,
  });

  @override
  State<_GameButton3D> createState() => _GameButton3DState();
}

class _GameButton3DState extends State<_GameButton3D> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final double topOffset = _isPressed ? 6.0 : 0.0;
    final double shadowHeight = 8.0;

    return GestureDetector(
      onTapDown: (_) {
        if (!widget.isLocked) setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        if (!widget.isLocked) setState(() => _isPressed = false);
      },
      onTapCancel: () {
        if (!widget.isLocked) setState(() => _isPressed = false);
      },
      onTap: widget.onTap,
      child: SizedBox(
        width: widget.size,
        height: widget.size + shadowHeight,
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: widget.size,
              child: Container(
                decoration: BoxDecoration(
                  color: widget.shadowColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 100),
              top: topOffset,
              left: 0,
              right: 0,
              bottom: shadowHeight - topOffset,
              child: Container(
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: widget.label != null && !widget.isLocked
                      ? Text(
                    widget.label!,
                    style: TextStyle(
                      fontSize: widget.size * 0.4,
                      fontWeight: FontWeight.w900,
                      color: widget.iconColor,
                    ),
                  )
                      : Icon(widget.icon, color: widget.iconColor, size: widget.size * 0.4),
                ),
              ),
            ),
            if (!widget.isLocked && !_isPressed)
              Positioned(
                top: widget.size * 0.15,
                left: widget.size * 0.2,
                child: Container(
                  width: widget.size * 0.25,
                  height: widget.size * 0.12,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}