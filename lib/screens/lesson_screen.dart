// lib/screens/lesson_screen.dart
import 'package:flutter/material.dart';
import 'package:code_for_fun/model/lesson_model.dart';
import 'package:code_for_fun/model/trail_model.dart';

// --- Imports adicionados ---
import 'package:provider/provider.dart';
import 'package:code_for_fun/providers/score_provider.dart';
// --- Fim dos imports adicionados ---


class LessonScreen extends StatefulWidget {
  final Lesson lesson;

  const LessonScreen({super.key, required this.lesson});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int _currentQuestionIndex = 0;
  Answer? _selectedAnswer;
  bool _isAnswerChecked = false;

  void _checkAnswer() {
    if (_selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma resposta antes de verificar!'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // --- Lógica de pontuação adicionada ---
    final bool isCorrect = _selectedAnswer?.isCorrect ?? false;
    if (isCorrect) {
      // Chama o provider para incrementar a pontuação
      Provider.of<ScoreProvider>(context, listen: false).incrementScore();
    }
    // --- Fim da lógica de pontuação ---

    setState(() {
      _isAnswerChecked = true;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.lesson.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _isAnswerChecked = false;
      });
    } else {
      // lição concluída!
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lição concluída com sucesso!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lesson.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sem Perguntas')),
        body: const Center(
          child: Text('Nenhuma pergunta encontrada para esta lição.'),
        ),
      );
    }

    final currentQuestion = widget.lesson.questions[_currentQuestionIndex];
    final bool isCorrect = _selectedAnswer?.isCorrect ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFF222831), // cor de fundo das questoes
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, currentQuestion),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      currentQuestion.text,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 32),
                    ...currentQuestion.answers.map((answer) {
                      return _buildAnswerButton(answer);
                    }).toList(),
                    const Spacer(),
                    if (!_isAnswerChecked)
                      _buildVerifyButton()
                    else
                      _buildFeedbackSection(isCorrect),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Question currentQuestion) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / widget.lesson.questions.length,
              backgroundColor: Colors.grey[700],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.favorite, color: Colors.red, size: 24),
        ],
      ),
    );
  }

  Widget _buildAnswerButton(Answer answer) {
    final bool isSelected = _selectedAnswer?.id == answer.id;
    final bool isCorrect = _isAnswerChecked && answer.isCorrect;
    final bool isIncorrect = _isAnswerChecked && !answer.isCorrect && isSelected;

    Color buttonColor;
    if (isIncorrect) {
      buttonColor = Colors.red[700]!;
    } else if (isCorrect) {
      buttonColor = Colors.green[700]!;
    } else if (isSelected) {
      buttonColor = Colors.grey[600]!;
    } else {
      buttonColor = Colors.grey[800]!;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: _isAnswerChecked ? null : () {
          setState(() {
            _selectedAnswer = answer;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: isSelected && !_isAnswerChecked
                ? const BorderSide(color: Colors.white, width: 2)
                : BorderSide.none,
          ),
        ),
        child: Text(
          answer.text,
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildVerifyButton() {
    return ElevatedButton(
      onPressed: _checkAnswer,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text(
        'VERIFICAR',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFeedbackSection(bool isCorrect) {
    return Container(
      color: isCorrect ? const Color(0xFF28A745) : const Color(0xFFDC3545),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isCorrect ? 'Correto!' : 'Incorreto!',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          ElevatedButton(
            onPressed: _nextQuestion,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: isCorrect ? const Color(0xFF28A745) : const Color(0xFFDC3545),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              _currentQuestionIndex < widget.lesson.questions.length - 1
                  ? 'CONTINUAR'
                  : 'FINALIZAR',
            ),
          ),
        ],
      ),
    );
  }
}