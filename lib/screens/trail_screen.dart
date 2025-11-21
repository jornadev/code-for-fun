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

  // Cor Principal (Roxo Deep Purple)
  final Color _mainPurple = const Color(0xFF673AB7);

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
    // Pega a cor de fundo padrão do tema (geralmente aquele cinza claro ou branco)
    final theme = Theme.of(context);
    final backgroundColor = theme.scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor, // Fundo limpo
      appBar: AppBar(
        backgroundColor: _mainPurple, // Apenas o topo é Roxo
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
      body: _isLoadingUserData
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
                style: TextStyle(color: Colors.grey[600]),
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

          return ListView.builder(
            padding: const EdgeInsets.only(top: 40, bottom: 100),
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
    // Curva Zig-Zag
    final double xOffset = math.sin(index * 2.5) * 80.0;

    // --- PALETA DE CORES ---
    Color circleColor;
    Color shadowColor;
    Color iconColor;
    IconData iconData;
    double buttonSize = 75.0;

    if (isCompleted) {
      // Completas: Dourado
      circleColor = Colors.amber;
      shadowColor = Colors.amber[800]!;
      iconColor = Colors.white;
      iconData = Icons.star_rounded;
    } else if (isCurrent) {
      // Atual: Roxo Principal (Destaque no fundo claro)
      circleColor = _mainPurple;
      shadowColor = const Color(0xFF4527A0); // Roxo mais escuro para sombra
      iconColor = Colors.white;
      iconData = Icons.play_arrow_rounded;
      buttonSize = 90.0; // Maior para chamar atenção
    } else {
      // Bloqueada: Cinza
      circleColor = Colors.grey[300]!;
      shadowColor = Colors.grey[400]!;
      iconColor = Colors.grey[500]!;
      iconData = Icons.lock;
    }

    return Center(
      child: SizedBox(
        width: double.infinity,
        height: 150,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. LINHA CONECTORA
            if (index < totalLength - 1)
              Transform.translate(
                offset: Offset(
                    (xOffset + (math.sin((index + 1) * 2.5) * 80.0)) / 2,
                    60 // Ajuste vertical
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
                          : Colors.grey.withOpacity(0.3), // Linha cinza suave se não completou
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),

            // 2. O BOTÃO 3D
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

                  // Título da Lição
                  // Agora usamos texto escuro pois o fundo é claro
                  if (!isLocked || isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            )
                          ]
                      ),
                      child: Text(
                        lesson.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isCurrent ? _mainPurple : AppColors.textDark,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),

            // 3. ELEMENTOS DECORATIVOS (Ícones cinzas no fundo claro)
            if (index % 3 == 0 && index > 0)
              Transform.translate(
                offset: Offset(-xOffset * 1.8, -30),
                child: Icon(
                  Icons.star,
                  color: Colors.grey.withOpacity(0.15), // Cinza bem clarinho
                  size: 40,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET DO BOTÃO 3D ---
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
            // Sombra (Base)
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
            // Botão (Topo)
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
                  child: widget.isLocked
                      ? Icon(widget.icon, color: widget.iconColor, size: widget.size * 0.4)
                      : Icon(widget.icon, color: widget.iconColor, size: widget.size * 0.5),
                ),
              ),
            ),
            // Brilho
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