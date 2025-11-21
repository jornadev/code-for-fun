import 'package:flutter/material.dart';
import 'package:code_for_fun/service/user_service.dart';

class ScoreProvider with ChangeNotifier {
  final UserService _userService = UserService();
  int _score = 0;
  List<String> _completedLessonIds = [];
  bool _isLoading = false;

  int get score => _score;
  bool get isLoading => _isLoading;
  List<String> get completedLessonIds => _completedLessonIds;

  Future<void> loadUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final scoreFuture = _userService.getUserScore();
      final lessonsFuture = _userService.getCompletedLessons();

      _score = await scoreFuture;
      _completedLessonIds = await lessonsFuture;
    } catch (e) {
      print("Erro ao carregar dados do usuário no provider: $e");
      _score = 0;
      _completedLessonIds = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> incrementScore() async {
    final int previousScore = _score;
    _score += 10;
    notifyListeners();

    try {
      await _userService.updateUserScore(_score);
    } catch (e) {
      print("Falha ao salvar pontuação no provider: $e");
      _score = previousScore;
      notifyListeners();
      throw Exception("Falha ao salvar pontuação.");
    }
  }

  Future<void> completeLesson(String lessonId) async {
    if (!_completedLessonIds.contains(lessonId)) {
      _completedLessonIds.add(lessonId);
      notifyListeners();
    }

    try {
      await _userService.completeLesson(lessonId);
    } catch (e) {
      print("Falha ao finalizar lição no provider: $e");
      _completedLessonIds.remove(lessonId);
      notifyListeners();
      throw Exception("Falha ao salvar seu progresso.");
    }
  }

  Future<void> resetAccountProgress() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _userService.resetUserProgress();

      _score = 0;
      _completedLessonIds = [];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }

  void resetScore() {
    _score = 0;
    _completedLessonIds = [];
    notifyListeners();
  }
}