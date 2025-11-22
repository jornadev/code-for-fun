import 'package:flutter/material.dart';
import 'package:code_for_fun/service/user_service.dart';

class ScoreProvider extends ChangeNotifier {
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
      final results = await Future.wait([
        _userService.getUserScore(),
        _userService.getCompletedLessons(),
      ]);

      _score = results[0] as int;
      _completedLessonIds = results[1] as List<String>;
    } catch (e) {
      print("Erro ao carregar dados do usuário no provider: $e");
      _score = 0;
      _completedLessonIds = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addScore(int points) async {
    final int previousScore = _score;

    _score += points;
    notifyListeners();

    try {
      await _userService.updateUserScore(_score);
    } catch (e) {
      print("Falha ao salvar pontuação no provider: $e");
      _score = previousScore;
      notifyListeners();
    }
  }

  Future<void> completeLesson(String lessonId) async {
    if (_completedLessonIds.contains(lessonId)) return;

    _completedLessonIds.add(lessonId);
    notifyListeners();

    try {
      await _userService.completeLesson(lessonId);
    } catch (e) {
      print("Falha ao finalizar lição no provider: $e");
      _completedLessonIds.remove(lessonId);
      notifyListeners();
    }
  }

  Future<void> resetAccountProgress() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _userService.resetUserProgress();

      _score = 0;
      _completedLessonIds = [];
    } catch (e) {
      print("Erro ao resetar conta: $e");
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}