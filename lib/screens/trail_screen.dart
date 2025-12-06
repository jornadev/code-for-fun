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

class _TrailScreenState extends State<TrailScreen> with TickerProviderStateMixin {
  final UserService _userService = UserService();
  final TrailService _trailService = TrailService();

  // CORES TEMA TECH/ESPAÇO
  final Color _mainPurple = const Color(0xFF673AB7);
  final Color _techPurpleLight = const Color(0xFF7E57C2);
  final Color _techPurpleDeep = const Color(0xFF24136A);

  Set<String> _completedLessonIds = {};
  bool _isLoadingUserData = true;
  late AnimationController _wobbleController;
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _loadUserData();

    _wobbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _wobbleController.dispose();
    _particleController.dispose();
    super.dispose();
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1))
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          widget.trail.title.toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            shadows: [Shadow(color: _mainPurple, offset: const Offset(0, 2), blurRadius: 10)],
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [const Color(0xFF311B92), const Color(0xFF000000)]
                  : [_techPurpleLight, _techPurpleDeep],
              stops: const [0.2, 1.0]
          ),
        ),
        child: Stack(
          children: [
            // CAMADA 0: Partículas
            ..._buildBackgroundParticles(MediaQuery.of(context).size),

            // CAMADA 1: Lista
            _isLoadingUserData
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : StreamBuilder<List<Lesson>>(
              stream: _trailService.getLessons(widget.trail.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }

                final lessons = snapshot.data ?? [];

                if (lessons.isEmpty) {
                  return const Center(
                    child: Text('Em breve novas aulas!', style: TextStyle(color: Colors.white)),
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
                  padding: const EdgeInsets.only(top: 120, bottom: 100),
                  itemCount: lessons.length + 1,
                  clipBehavior: Clip.none,
                  itemBuilder: (context, index) {
                    if (index < lessons.length) {
                      final lesson = lessons[index];
                      final bool isCompleted = _completedLessonIds.contains(lesson.id);
                      final bool isCurrent = (index == unlockedIndex);
                      final bool isLocked = index > unlockedIndex;

                      return _buildEnhancedPathNode(
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
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBackgroundParticles(Size screenSize) {
    final random = math.Random(42);
    return List.generate(20, (index) {
      final size = random.nextDouble() * 40 + 10;
      final initialX = random.nextDouble() * screenSize.width;
      final initialY = random.nextDouble() * screenSize.height;
      final speed = random.nextDouble() * 0.1 + 0.05;

      return AnimatedBuilder(
        animation: _particleController,
        builder: (context, child) {
          double currentY = initialY - (_particleController.value * screenSize.height * speed);
          if (currentY < -size) currentY += screenSize.height + size + (random.nextDouble() * 100);

          return Positioned(
            left: initialX,
            top: currentY,
            child: Opacity(
              opacity: random.nextDouble() * 0.1 + 0.02,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Colors.white, _mainPurple.withOpacity(0.0)],
                    )
                ),
              ),
            ),
          );
        },
      );
    });
  }


  Widget _buildEnhancedPathNode(
      BuildContext context,
      int index,
      int totalLength,
      Lesson lesson,
      bool isCompleted,
      bool isCurrent,
      bool isLocked,
      bool isDark,
      ) {
    final double xOffset = math.sin(index * 1.8) * 90.0;
    final double nextXOffset = math.sin((index + 1) * 1.8) * 90.0;

    final lessonNumber = index + 1;

    Color circleColor;
    Color shadowColor;
    Color iconColor;
    double buttonSize = 80.0;

    if (isCompleted) {
      circleColor = Colors.amber;
      shadowColor = Colors.amber[800]!;
      iconColor = Colors.white;
    } else if (isCurrent) {
      circleColor = _mainPurple;
      shadowColor = const Color(0xFF4527A0);
      iconColor = Colors.white;
      buttonSize = 100.0;
    } else {
      circleColor = isDark ? const Color(0xFF424242) : Colors.grey[300]!.withOpacity(0.5);
      shadowColor = isDark ? Colors.black54 : Colors.grey[700]!.withOpacity(0.3);
      iconColor = isDark ? Colors.white30 : Colors.white54;
    }

    String? labelContent;
    IconData iconContent = Icons.lock;

    if (isLocked) {
      iconContent = Icons.lock_outline_rounded;
    } else if (isCompleted) {
      iconContent = Icons.star_rounded;
    } else {
      labelContent = '$lessonNumber';
    }

    return SizedBox(
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [

          // ===============================================
          // 1. O CAMINHO (AGORA FINO E NEON)
          // ===============================================
          if (index < totalLength)
            Positioned(
              top: 60,
              child: Transform.translate(
                offset: Offset((xOffset + nextXOffset) / 2, 0),
                child: Transform.rotate(
                  angle: -math.atan((nextXOffset - xOffset) / 120),
                  child: Container(
                    width: 6, // MUITO MAIS FINO (era 32)
                    height: 130, // Um pouco maior para garantir a conexão
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6), // Núcleo branco
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          // O Brilho (Glow) que dá o volume visual sem pesar
                          BoxShadow(
                            color: _mainPurple.withOpacity(0.6),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                    ),
                  ),
                ),
              ),
            ),

          // 2. Space Debris
          ..._buildSpaceDebris(index, xOffset),


          // 3. Pato
          if (isCurrent)
            Positioned(
              left: xOffset > 0 ? null : MediaQuery.of(context).size.width / 2 + xOffset + 65,
              right: xOffset > 0 ? MediaQuery.of(context).size.width / 2 - xOffset + 65 : null,
              top: 20,
              child: AnimatedBuilder(
                animation: _wobbleController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, math.sin(_wobbleController.value * 2 * math.pi) * 6),
                    child: child,
                  );
                },
                child: Image.asset(
                  'assets/images/duck.png',
                  width: 75,
                  fit: BoxFit.contain,
                ),
              ),
            ),

          // 4. Status Icons
          if (isCompleted) ...[
            _buildDecoration(xOffset, -55, -35, Icons.code_rounded, Colors.amber.withOpacity(0.8), 22),
            _buildDecoration(xOffset, 55, -15, Icons.auto_awesome_rounded, Colors.amberAccent, 18),
          ],

          // 5. Button
          Transform.translate(
            offset: Offset(xOffset, 0),
            child: _GameButton3D(
              size: buttonSize,
              color: circleColor,
              shadowColor: shadowColor,
              icon: iconContent,
              iconColor: iconColor,
              isLocked: isLocked,
              isCurrent: isCurrent,
              label: labelContent,
              onTap: isLocked
                  ? null
                  : () => _navigateToLesson(context, lesson),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSpaceDebris(int index, double xOffset) {
    final random = math.Random(index);
    List<Widget> debris = [];

    for (int i = 0; i < 3; i++) {
      double offsetX = (random.nextDouble() * 140 - 70);
      double offsetY = (random.nextDouble() * 100 - 50);
      double size = random.nextDouble() * 6 + 4;
      bool isStar = random.nextBool();

      debris.add(
          Positioned(
            left: MediaQuery.of(context).size.width / 2 + xOffset + offsetX,
            top: 80 + offsetY,
            child: AnimatedBuilder(
              animation: _wobbleController,
              builder: (context, child) {
                double wobble = math.sin((_wobbleController.value + random.nextDouble()) * 2 * math.pi);
                return Transform.translate(
                  offset: Offset(wobble * 3, wobble * -3),
                  child: Opacity(
                    opacity: random.nextDouble() * 0.4 + 0.2,
                    child: Icon(
                      isStar ? Icons.star_rate_rounded : Icons.circle,
                      size: size,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          )
      );
    }
    return debris;
  }

  Widget _buildDecoration(double baseX, double offsetX, double offsetY, IconData icon, Color color, double size) {
    return Positioned(
        left: MediaQuery.of(context).size.width / 2 + baseX + offsetX,
        top: 80 + offsetY,
        child: AnimatedBuilder(
          animation: _wobbleController,
          builder: (context, child) {
            return Transform.translate(
                offset: Offset(0, math.cos(_wobbleController.value * 2 * math.pi + offsetX/10) * 4),
                child: child
            );
          },
          child: Icon(icon, color: color, size: size),
        )
    );
  }

  Widget _buildFinishLine(BuildContext context, bool isTrailCompleted, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 60, bottom: 40),
      child: Center(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (isTrailCompleted)
                  Positioned(
                    child: Container(
                      width: 140, height: 140,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.amber.withOpacity(0.5), blurRadius: 60, spreadRadius: 25),
                            BoxShadow(color: _mainPurple.withOpacity(0.3), blurRadius: 30, spreadRadius: 5),
                          ]
                      ),
                    ),
                  ),
                _GameButton3D(
                  size: 110,
                  color: isTrailCompleted ? Colors.amber : Colors.grey.shade400.withOpacity(0.2),
                  shadowColor: isTrailCompleted ? Colors.amber[800]! : Colors.grey.shade900.withOpacity(0.3),
                  icon: Icons.emoji_events_rounded,
                  iconColor: Colors.white,
                  isLocked: false,
                  isCurrent: isTrailCompleted,
                ),
              ],
            ),

            const SizedBox(height: 35),

            Text(
              isTrailCompleted ? 'MISSÃO CUMPRIDA!' : 'DESTINO FINAL',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: isTrailCompleted ? Colors.amber : Colors.white,
                  letterSpacing: 1.5,
                  shadows: [
                    Shadow(color: isTrailCompleted ? Colors.amberAccent : Colors.black38, offset: const Offset(0,2), blurRadius: 10)
                  ]
              ),
            ),

            const SizedBox(height: 15),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                isTrailCompleted
                    ? 'Você dominou este setor da galáxia da programação!'
                    : 'Complete todos os módulos para conquistar este troféu!',
                style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                    height: 1.4
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// WIDGET DO BOTÃO 3D (Mantido igual)
// ==========================================
class _GameButton3D extends StatefulWidget {
  final double size;
  final Color color;
  final Color shadowColor;
  final IconData icon;
  final Color iconColor;
  final bool isLocked;
  final bool isCurrent;
  final String? label;
  final VoidCallback? onTap;

  const _GameButton3D({
    required this.size,
    required this.color,
    required this.shadowColor,
    required this.icon,
    required this.iconColor,
    required this.isLocked,
    this.isCurrent = false,
    this.label,
    this.onTap,
  });

  @override
  State<_GameButton3D> createState() => _GameButton3DState();
}

class _GameButton3DState extends State<_GameButton3D> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double topOffset = _isPressed ? 8.0 : 0.0;
    final double shadowHeight = 10.0;

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
          clipBehavior: Clip.none,
          children: [
            if (widget.isCurrent && !widget.isLocked)
              Positioned(
                top: shadowHeight, left: 0, right: 0, bottom: 0,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: widget.color.withOpacity(0.6 - (_pulseController.value * 0.3)),
                              blurRadius: 20 + (_pulseController.value * 15),
                              spreadRadius: 5 + (_pulseController.value * 10),
                            )
                          ]
                      ),
                    );
                  },
                ),
              ),
            Positioned(
              bottom: 0,
              left: 2,
              right: 2,
              height: widget.size,
              child: Container(
                decoration: BoxDecoration(
                    color: widget.shadowColor,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0,4))]
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOutBack,
              top: topOffset,
              left: 0,
              right: 0,
              bottom: shadowHeight - topOffset,
              child: Container(
                decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.25), width: 2)
                ),
                child: Center(
                  child: widget.label != null && !widget.isLocked
                      ? Text(
                    widget.label!,
                    style: TextStyle(
                        fontSize: widget.size * 0.45,
                        fontWeight: FontWeight.w900,
                        color: widget.iconColor,
                        shadows: [Shadow(color: Colors.black38, offset: Offset(1,1), blurRadius: 3)]
                    ),
                  )
                      : Icon(widget.icon, color: widget.iconColor, size: widget.size * 0.45),
                ),
              ),
            ),
            if (!widget.isLocked && !_isPressed)
              Positioned(
                top: widget.size * 0.1,
                left: widget.size * 0.2,
                child: Container(
                  width: widget.size * 0.3,
                  height: widget.size * 0.2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.white.withOpacity(0.6), Colors.white.withOpacity(0.1)]
                    ),
                    borderRadius: const BorderRadius.all(Radius.elliptical(30, 20)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}