import 'package:flutter/material.dart';
import 'package:code_for_fun/model/trail_model.dart';
import 'package:code_for_fun/model/lesson_model.dart';
import 'package:code_for_fun/screens/lesson_screen.dart';
import 'package:code_for_fun/constants/app_colors.dart';
import 'package:code_for_fun/service/user_service.dart';

class TrailScreen extends StatefulWidget {
  final Trail trail;

  const TrailScreen({super.key, required this.trail});

  @override
  State<TrailScreen> createState() => _TrailScreenState();
}

class _TrailScreenState extends State<TrailScreen> {
  late List<bool> _lessonCompletionStatus;
  late int _unlockedLessonIndex;
  bool _isLoading = true;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _lessonCompletionStatus =
        List.filled(widget.trail.lessons.length, false);
    _unlockedLessonIndex = 0;
    _loadTrailState();
  }

  Future<void> _loadTrailState() async {
    setState(() {
      _isLoading = true;
    });

    final completedLessonIds = await _userService.getCompletedLessons();
    List<bool> newStatus = [];
    int newUnlockedIndex = 0;
    bool foundFirstUnlocked = false;

    for (int i = 0; i < widget.trail.lessons.length; i++) {
      final lessonId = widget.trail.lessons[i].id;
      final bool isCompleted = completedLessonIds.contains(lessonId);

      newStatus.add(isCompleted);

      if (!isCompleted && !foundFirstUnlocked) {
        newUnlockedIndex = i;
        foundFirstUnlocked = true;
      }
    }

    if (!foundFirstUnlocked && newStatus.isNotEmpty) {
      newUnlockedIndex = newStatus.length;
    }

    setState(() {
      _lessonCompletionStatus = newStatus;
      _unlockedLessonIndex = newUnlockedIndex;
      _isLoading = false;
    });
  }

  void _navigateToLesson(BuildContext context, Lesson lesson) async {
    final bool? didCompleteModule = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => LessonScreen(lesson: lesson),
      ),
    );

    if (didCompleteModule == true) {
      _loadTrailState();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: AppColors.textDark,
        ),
        title: Text(
          widget.trail.title,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),

      backgroundColor: AppColors.backgroundColor,
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: AppColors.blue,
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: widget.trail.lessons.length,
        itemBuilder: (context, index) {
          final lesson = widget.trail.lessons[index];

          final bool isCompleted = _lessonCompletionStatus[index];
          final bool isCurrent = (index == _unlockedLessonIndex);
          final bool isLocked = (index > _unlockedLessonIndex);
          final bool isUnlocked = (isCompleted || isCurrent) && !isLocked;

          return _buildLessonCard(
            lesson: lesson,
            isCompleted: isCompleted,
            isCurrent: isCurrent,
            isUnlocked: isUnlocked,
          );
        },
      ),
    );
  }

  Widget _buildLessonCard({
    required Lesson lesson,
    required bool isCompleted,
    required bool isCurrent,
    required bool isUnlocked,
  }) {
    IconData iconData;
    Color iconColor;
    Color iconBackgroundColor;
    Color titleColor;
    Color borderColor;

    if (isCompleted) {
      // Concluído: ícone azul, borda azul
      iconData = Icons.check;
      iconColor = AppColors.white;
      iconBackgroundColor = AppColors.blue;
      titleColor = AppColors.textDark;
      borderColor = AppColors.blue.withOpacity(0.4);
    } else if (isCurrent && isUnlocked) {
      // Módulo atual desbloqueado
      iconData = Icons.play_arrow_rounded;
      iconColor = AppColors.textDark;
      iconBackgroundColor = AppColors.inputGray;
      titleColor = AppColors.textDark;
      borderColor = AppColors.inputGray;
    } else {
      // Bloqueado
      iconData = Icons.lock_rounded;
      iconColor = AppColors.textLight;
      iconBackgroundColor = AppColors.inputGray.withOpacity(0.6);
      titleColor = AppColors.textLight;
      borderColor = Colors.transparent;
    }

    return Opacity(
      opacity: isUnlocked ? 1.0 : 0.7,
      child: InkWell(
        onTap: isUnlocked ? () => _navigateToLesson(context, lesson) : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: borderColor == Colors.transparent ? 0.6 : 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconData,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  lesson.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: titleColor,
                  ),
                ),
              ),
              if (isUnlocked)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textLight,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
