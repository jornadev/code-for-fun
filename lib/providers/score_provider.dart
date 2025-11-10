
import 'package:flutter/material.dart';
import 'package:code_for_fun/service/user_service.dart';

class ScoreProvider with ChangeNotifier {
  final UserService _userService = UserService();
  int _score = 0;
  bool _isLoading = false;

  int get score => _score;
  bool get isLoading => _isLoading;

  Future<void> loadUserScore() async {
    _isLoading = true;
    notifyListeners();

    _score = await _userService.getUserScore();

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


    }

  }

  void resetScore() {
    _score = 0;
    notifyListeners();
  }
}