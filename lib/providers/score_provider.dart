import 'package:flutter/material.dart';
// Certifique-se que o nome do projeto 'code_for_fun' está correto
import 'package:code_for_fun/service/user_service.dart';

class ScoreProvider with ChangeNotifier {
  final UserService _userService = UserService();
  int _score = 0;
  bool _isLoading = false;

  int get score => _score;
  bool get isLoading => _isLoading;

  /// Carrega a pontuação inicial do usuário (do Firebase)
  Future<void> loadUserScore() async {
    _isLoading = true;
    notifyListeners(); // Notifica a UI que está carregando

    _score = await _userService.getUserScore();

    _isLoading = false;
    notifyListeners(); // Notifica a UI com a nova pontuação
  }

  /// Incrementa a pontuação (10 pontos por acerto)
  Future<void> incrementScore() async {
    _score += 10;
    notifyListeners(); // Atualiza a UI imediatamente (para resposta rápida)

    // Salva o novo total no Firebase em segundo plano
    await _userService.updateUserScore(_score);
  }

  /// Zera a pontuação (para quando o usuário fizer logout)
  void resetScore() {
    _score = 0;
    notifyListeners();
  }
}