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
    final theme = Theme.of(context);
    final backgroundColor = theme.scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.trail.title.toUpperCase(),
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoadingUserData
          ? const Center(child: CircularProgressIndicator(color: Colors.purple)) // Loading roxo
          : StreamBuilder<List<Lesson>>(
        stream: _trailService.getLessons(widget.trail.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.purple));
          }

          final lessons = snapshot.data ?? [];

          if (lessons.isEmpty) {
            return const Center(child: Text('Em breve novas aulas!'));
          }

          int unlockedIndex = 0;
          for (int i = 0; i < lessons.length; i++) {
            if (!_completedLessonIds.contains(lessons[i].id)) {
              unlockedIndex = i;
              break;
            }
            if (i == lessons.length - 1) unlockedIndex = lessons.length;
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 20, bottom: 60),
            itemCount: lessons.length,
            itemBuilder: (context, index) {
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
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPathNode(
      BuildContext context,
      int index,
      int totalLength,
      Lesson lesson,
      bool isCompleted,
      bool isCurrent,
      bool isLocked,
      ) {
    final double xOffset = math.sin(index * 2.5) * 80.0;

    // --- PALETA DE CORES ROXA ---
    Color circleColor;
    Color shadowColor;
    Color iconColor;
    IconData iconData;
    double buttonSize = 70.0;

    if (isCompleted) {
      // Roxo Escuro / Conquistado
      circleColor = const Color(0xFF8E24AA); // Roxo Médio (Purple 600)
      shadowColor = const Color(0xFF4A148C); // Roxo Bem Escuro (Purple 900)
      iconColor = Colors.amberAccent; // Estrela Dourada para contraste
      iconData = Icons.star_rounded;
    } else if (isCurrent) {
      // Roxo Vibrante / Ação
      circleColor = const Color(0xFFE040FB); // Roxo Neon (PurpleAccent 100/200)
      shadowColor = const Color(0xFFAA00FF); // Roxo Forte (PurpleAccent 700)
      iconColor = Colors.white;
      iconData = Icons.play_arrow_rounded;
      buttonSize = 85.0; // Um pouco maior para destaque
    } else {
      // Bloqueado (Mantém cinza para não poluir)
      circleColor = Colors.grey[300]!;
      shadowColor = Colors.grey[400]!;
      iconColor = Colors.grey[500]!;
      iconData = Icons.lock;
    }

    if (Theme.of(context).brightness == Brightness.dark && isLocked) {
      circleColor = const Color(0xFF2A2A2D);
      shadowColor = Colors.black;
      iconColor = Colors.grey[600]!;
    }

    return Center(
      child: SizedBox(
        width: double.infinity,
        height: 140,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // LINHA CONECTORA
            if (index < totalLength - 1)
              Transform.translate(
                offset: Offset(
                    (xOffset + (math.sin((index + 1) * 2.5) * 80.0)) / 2,
                    55
                ),
                child: Transform.rotate(
                  angle: -math.atan(
                      (math.sin((index + 1) * 2.5) * 80.0 - xOffset) / 100
                  ),
                  child: Container(
                    width: 12,
                    height: 70,
                    decoration: BoxDecoration(
                      // A linha fica roxa se já completou, cinza se não
                      color: isCompleted ? const Color(0xFFBA68C8).withOpacity(0.5) : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),

            // BOTÃO 3D
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
                    icon: iconData,
                    iconColor: iconColor,
                    isLocked: isLocked,
                    onTap: isLocked
                        ? null
                        : () => _navigateToLesson(context, lesson),
                  ),

                  const SizedBox(height: 8),

                  if (!isLocked || isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ]
                      ),
                      child: Text(
                        lesson.title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          // Se for o atual, o texto fica Roxo para combinar
                          color: isCurrent ? const Color(0xFF8E24AA) : (isLocked ? Colors.grey : AppColors.textDark),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),

            // ÍCONE DECORATIVO (Escola/Troféu)
            if (index % 3 == 0 && index > 0)
              Transform.translate(
                offset: Offset(-xOffset * 1.8, -20),
                child: Icon(
                  Icons.emoji_events, // Troféu sutil ao fundo
                  color: Colors.deepPurple.withOpacity(0.05), // Roxo bem clarinho
                  size: 48,
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
  final VoidCallback? onTap;

  const _GameButton3D({
    required this.size,
    required this.color,
    required this.shadowColor,
    required this.icon,
    required this.iconColor,
    required this.isLocked,
    this.onTap,
  });

  @override
  State<_GameButton3D> createState() => _GameButton3DState();
}

class _GameButton3DState extends State<_GameButton3D> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final double topOffset = _isPressed ? 4.0 : 0.0;
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
            // Sombra
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
            // Botão
            AnimatedPositioned(
              duration: const Duration(milliseconds: 50),
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
                  child: widget.isLocked
                      ? Icon(widget.icon, color: widget.iconColor, size: widget.size * 0.4)
                      : Icon(widget.icon, color: widget.iconColor, size: widget.size * 0.5),
                ),
              ),
            ),
            // Brilho
            if (!widget.isLocked && !_isPressed)
              Positioned(
                top: 10,
                left: 15,
                child: Container(
                  width: widget.size * 0.2,
                  height: widget.size * 0.1,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}