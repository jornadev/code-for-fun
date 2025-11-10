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
        title: Text(widget.trail.title),
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: AppColors.white,
      ),

      backgroundColor: AppColors.lightGray,
      body: _isLoading
          ? const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryPurple,
          ))

          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: widget.trail.lessons.length,
        itemBuilder: (context, index) {
          final lesson = widget.trail.lessons[index];


          final bool isCompleted = _lessonCompletionStatus[index];
          final bool isCurrent = (index == _unlockedLessonIndex);
          final bool isLocked = (index > _unlockedLessonIndex);
          final bool isUnlocked = (isCompleted || isCurrent);

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

    if (isCompleted) {
      iconData = Icons.check;
      iconColor = AppColors.white;
      iconBackgroundColor = AppColors.primaryPurple;
    } else if (isCurrent) {
      iconData = Icons.lock_open;
      iconColor = AppColors.white;
      iconBackgroundColor = AppColors.secondaryPurple;
    } else {

      iconData = Icons.lock;
      iconColor = AppColors.textLight;
      iconBackgroundColor = AppColors.inputGray;
    }


    return Card(
      elevation: isUnlocked ? 2 : 0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        enabled: isUnlocked,
        onTap: isUnlocked ? () => _navigateToLesson(context, lesson) : null,

        leading: CircleAvatar(
          radius: 24,
          backgroundColor: iconBackgroundColor,
          child: Icon(iconData, color: iconColor),
        ),

        title: Text(
          lesson.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        trailing: isUnlocked ? const Icon(Icons.chevron_right) : null,
      ),
    );
  }
}

