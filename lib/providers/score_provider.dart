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

  // Carrega os dados do Firebase ao iniciar o app
  Future<void> loadUserData() async {
    _isLoading = true;
    // Usamos notifyListeners aqui para avisar que começou a carregar
    // (Se der erro de 'setState during build', pode remover esta linha específica)
    notifyListeners();

    try {
      // Busca score e lições em paralelo para ser mais rápido
      final results = await Future.wait([
        _userService.getUserScore(),
        _userService.getCompletedLessons(),
      ]);

      _score = results[0] as int;
      _completedLessonIds = results[1] as List<String>;
    } catch (e) {
      print("Erro ao carregar dados do usuário no provider: $e");
      // Em caso de erro, mantemos zerado para não quebrar a UI
      _score = 0;
      _completedLessonIds = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Adiciona pontos (Otimista: Atualiza a tela ANTES do banco)
  Future<void> addScore(int points) async {
    final int previousScore = _score;

    // 1. Atualiza a UI imediatamente para o usuário não sentir lag
    _score += points;
    notifyListeners();

    try {
      // 2. Tenta salvar no banco em segundo plano
      await _userService.updateUserScore(_score);
    } catch (e) {
      print("Falha ao salvar pontuação no provider: $e");
      // 3. Se der erro, desfaz a alteração (Rollback)
      _score = previousScore;
      notifyListeners();
    }
  }

  // Marca lição como completa (Otimista)
  Future<void> completeLesson(String lessonId) async {
    // Se já completou, não faz nada para não duplicar ou gastar internet
    if (_completedLessonIds.contains(lessonId)) return;

    // 1. Atualiza a UI imediatamente
    _completedLessonIds.add(lessonId);
    notifyListeners();

    try {
      // 2. Tenta salvar no banco
      await _userService.completeLesson(lessonId);
    } catch (e) {
      print("Falha ao finalizar lição no provider: $e");
      // 3. Se der erro, desfaz (Rollback)
      _completedLessonIds.remove(lessonId);
      notifyListeners();
    }
  }

  // Reseta todo o progresso (Útil para testes ou configurações)
  Future<void> resetAccountProgress() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _userService.resetUserProgress();

      // Reseta estado local
      _score = 0;
      _completedLessonIds = [];
    } catch (e) {
      print("Erro ao resetar conta: $e");
      throw e; // Repassa o erro para a tela tratar se quiser
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}