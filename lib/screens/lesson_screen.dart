import 'package:flutter/material.dart';
import 'package:code_for_fun/model/lesson_model.dart';
import 'package:provider/provider.dart';
import 'package:code_for_fun/providers/score_provider.dart';
import 'package:code_for_fun/service/user_service.dart';
import 'package:code_for_fun/constants/app_colors.dart';

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


  bool _isFinishing = false;


  final UserService _userService = UserService();

  Question get _currentQuestion =>
      widget.lesson.questions[_currentQuestionIndex];

  bool get _isLastQuestion =>
      _currentQuestionIndex == widget.lesson.questions.length - 1;

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

    final bool isCorrect = _selectedAnswer!.isCorrect;

    if (isCorrect) {
      Provider.of<ScoreProvider>(context, listen: false).incrementScore();
    }

    setState(() {
      _isAnswerChecked = true;
    });
  }


  void _handleContinue(bool isCorrect) async {
    if (!isCorrect) {

      setState(() {
        _selectedAnswer = null;
        _isAnswerChecked = false;
      });
      return;
    }


    if (_isLastQuestion) {

      if (_isFinishing) return;

      setState(() {
        _isFinishing = true;
      });

      try {

        await _userService.completeLesson(widget.lesson.id);


        if (mounted) {
          _showCompletionDialog();
        }
      } catch (e) {

        if (mounted) {
          setState(() {
            _isFinishing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao salvar progresso. Tente novamente.')),
          );
        }
      }
    } else {

      _goToNextQuestion();
    }
  }


  void _goToNextQuestion() {
    setState(() {
      _currentQuestionIndex++;
      _selectedAnswer = null;
      _isAnswerChecked = false;
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Módulo Concluído!'),
        content: const Text(
            'Parabéns, você completou todos os desafios deste módulo.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(true);
            },
            child: const Text('Continuar Trilha'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.title),
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pergunta ${_currentQuestionIndex + 1} de ${widget.lesson.questions.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentQuestion.text,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ..._currentQuestion.answers.map((answer) {
                    return _buildAnswerOption(answer);
                  }).toList(),
                ],
              ),
            ),
          ),
          if (!_isAnswerChecked) _buildCheckButton(),
          if (_isAnswerChecked)
            _buildFeedbackSection(_selectedAnswer!.isCorrect, _isLastQuestion),
        ],
      ),
    );
  }

  Widget _buildAnswerOption(Answer answer) {
    final bool isSelected = _selectedAnswer?.id == answer.id;
    Color? borderColor;
    Color? tileColor;

    if (_isAnswerChecked) {
      if (answer.isCorrect) {
        borderColor = Colors.green;
        tileColor = Colors.green.withOpacity(0.1);
      } else if (isSelected && !answer.isCorrect) {
        borderColor = Colors.red;
        tileColor = Colors.red.withOpacity(0.1);
      }
    } else if (isSelected) {
      borderColor = AppColors.secondaryPurple;
      tileColor = AppColors.secondaryPurple.withOpacity(0.1);
    }

    return GestureDetector(
      onTap: _isAnswerChecked ? null : () {
        setState(() {
          _selectedAnswer = answer;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: tileColor ?? AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor ?? AppColors.inputGray,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: borderColor ?? AppColors.textLight,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                answer.text,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _checkAnswer,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondaryPurple,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
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
      ),
    );
  }


  Widget _buildFeedbackSection(bool isCorrect, bool isLastQuestion) {
    final String buttonText = isCorrect
        ? (isLastQuestion ? 'FINALIZAR' : 'PRÓXIMA')
        : 'TENTAR DE NOVO';

    return Container(
      color: isCorrect ? const Color(0xFF28A745) : const Color(0xFFDC3545),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isCorrect ? 'Correto!' : 'Ops! Tente de novo.',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          ElevatedButton(

            onPressed: (isCorrect && _isFinishing) ? null : () => _handleContinue(isCorrect),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor:
              isCorrect ? const Color(0xFF28A745) : const Color(0xFFDC3545),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: (isCorrect && _isFinishing)
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Color(0xFF28A745),
                strokeWidth: 3,
              ),
            )
                : Text(buttonText),
          ),
        ],
      ),
    );
  }

}