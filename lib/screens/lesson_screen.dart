import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:code_for_fun/model/lesson_model.dart';
import 'package:code_for_fun/providers/score_provider.dart';
import 'package:code_for_fun/constants/app_colors.dart';

class LessonScreen extends StatefulWidget {
  final Lesson lesson;

  const LessonScreen({super.key, required this.lesson});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  // Cores do Tema
  final Color _mainPurple = const Color(0xFF673AB7);
  final Color _correctGreen = const Color(0xFF58CC02);
  final Color _wrongRed = const Color(0xFFFF4B4B);

  int _currentQuestionIndex = 0;
  Answer? _selectedAnswer;
  bool _isAnswerChecked = false;
  bool _isFinishing = false;

  Question get _currentQuestion =>
      widget.lesson.questions[_currentQuestionIndex];

  bool get _isLastQuestion =>
      _currentQuestionIndex == widget.lesson.questions.length - 1;

  void _checkAnswer() {
    if (_selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Por favor, selecione uma resposta.',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: _mainPurple,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
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
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _wrongRed,
      ),
    );
  }

  Future<void> _handleContinue(bool isCorrect) async {
    // Se errou, apenas reseta para tentar de novo (não avança)
    if (!isCorrect) {
      setState(() {
        _selectedAnswer = null;
        _isAnswerChecked = false;
      });
      return;
    }

    if (_isFinishing) return;

    final scoreProvider = Provider.of<ScoreProvider>(context, listen: false);

    try {
      if (_isLastQuestion) {
        setState(() => _isFinishing = true);
        await scoreProvider.addScore(10);
        await scoreProvider.completeLesson(widget.lesson.id);

        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        setState(() => _isFinishing = true);
        await scoreProvider.addScore(10);
        _nextQuestion();
        setState(() => _isFinishing = false);
      }
    } catch (e) {
      _showErrorSnackBar("Erro ao salvar progresso: $e");
      if (mounted) setState(() => _isFinishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double progress = (_currentQuestionIndex + 1) / widget.lesson.questions.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.grey[400], size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 16,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(_mainPurple),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    _currentQuestion.text,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 40),

                  ..._currentQuestion.answers
                      .map((answer) => _buildAnswerOption(answer))
                      .toList(),
                ],
              ),
            ),
          ),

          if (!_isAnswerChecked)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _checkAnswer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _mainPurple,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'VERIFICAR',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomSheet: _isAnswerChecked ? _buildFeedbackSheet() : null,
    );
  }

  Widget _buildAnswerOption(Answer answer) {
    final bool isSelected = _selectedAnswer == answer;

    // Configuração Padrão (Neutro)
    Color borderColor = Colors.grey[300]!;
    Color backgroundColor = Colors.white;
    Color textColor = AppColors.textDark;
    IconData? statusIcon;
    Color? statusIconColor;
    Color? statusBoxColor;

    // --- LÓGICA DE CORES ---
    if (_isAnswerChecked) {
      if (isSelected) {
        if (answer.isCorrect) {
          // Usuário selecionou a CERTA -> Verde
          borderColor = _correctGreen;
          backgroundColor = _correctGreen.withOpacity(0.1);
          textColor = _correctGreen;
          statusIcon = Icons.check;
          statusIconColor = Colors.white;
          statusBoxColor = _correctGreen;
        } else {
          // Usuário selecionou a ERRADA -> Vermelho
          borderColor = _wrongRed;
          backgroundColor = _wrongRed.withOpacity(0.1);
          textColor = _wrongRed;
          statusIcon = Icons.close;
          statusIconColor = Colors.white;
          statusBoxColor = _wrongRed;
        }
      } else {
        // Opções NÃO selecionadas (Incluindo a certa se o usuário errou)
        // Mantemos neutro para não dar spoiler
        borderColor = Colors.grey[200]!;
        textColor = Colors.grey[400]!; // Deixa um pouco mais apagado
      }
    } else if (isSelected) {
      // Selecionado (ainda não verificado) -> Roxo
      borderColor = _mainPurple;
      backgroundColor = _mainPurple.withOpacity(0.1);
      textColor = _mainPurple;
      statusIcon = Icons.check;
      statusIconColor = Colors.white;
      statusBoxColor = _mainPurple;
    }

    return GestureDetector(
      onTap: _isAnswerChecked
          ? null
          : () {
        setState(() {
          _selectedAnswer = answer;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            // Borda mais grossa se estiver selecionado
            width: (isSelected || (_isAnswerChecked && isSelected)) ? 2.5 : 1.5,
          ),
          boxShadow: isSelected && !_isAnswerChecked
              ? [
            BoxShadow(
              color: _mainPurple.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ]
              : [],
        ),
        child: Row(
          children: [
            // Caixa do ícone (Check, X ou vazio)
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: statusBoxColor ?? borderColor,
                  width: 2,
                ),
                color: statusBoxColor ?? Colors.transparent,
              ),
              child: statusIcon != null
                  ? Icon(statusIcon, size: 20, color: statusIconColor)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                answer.text,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackSheet() {
    if (_selectedAnswer == null) return const SizedBox.shrink();

    final bool isCorrect = _selectedAnswer!.isCorrect;

    // Cores e Textos do BottomSheet
    final Color sheetColor = isCorrect ? _correctGreen : _wrongRed;
    final String title = isCorrect ? 'Incrível!' : 'Incorreto';
    final String btnText = isCorrect
        ? (_isLastQuestion ? 'CONCLUIR' : 'CONTINUAR')
        : 'TENTAR NOVAMENTE';

    final IconData feedbackIcon = isCorrect
        ? Icons.check_circle_rounded
        : Icons.cancel_rounded;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: sheetColor.withOpacity(0.2), width: 2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(feedbackIcon, color: sheetColor, size: 40),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: sheetColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (isCorrect && _isFinishing)
                    ? null
                    : () => _handleContinue(isCorrect),
                style: ElevatedButton.styleFrom(
                  backgroundColor: sheetColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: (isCorrect && _isFinishing)
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
                    : Text(
                  btnText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}