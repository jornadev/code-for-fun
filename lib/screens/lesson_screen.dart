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
  int _currentQuestionIndex = 0;
  Answer? _selectedAnswer;
  bool _isAnswerChecked = false;
  bool _isFinishing = false; // Controla o estado de carregamento ao salvar

  Question get _currentQuestion =>
      widget.lesson.questions[_currentQuestionIndex];

  bool get _isLastQuestion =>
      _currentQuestionIndex == widget.lesson.questions.length - 1;

  void _checkAnswer() {
    if (_selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione uma resposta.'),
          backgroundColor: AppColors.red,
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
        backgroundColor: AppColors.red,
      ),
    );
  }

  Future<void> _handleContinue(bool isCorrect) async {
    // Se errou, apenas reseta para tentar de novo
    if (!isCorrect) {
      setState(() {
        _selectedAnswer = null;
        _isAnswerChecked = false;
      });
      return;
    }

    // Evita cliques duplos enquanto salva
    if (_isFinishing) return;

    final scoreProvider = Provider.of<ScoreProvider>(context, listen: false);

    try {
      if (_isLastQuestion) {
        // --- FINALIZANDO A LIÇÃO ---
        setState(() {
          _isFinishing = true;
        });

        // 1. Adiciona pontos pela última pergunta (10 pontos)
        await scoreProvider.addScore(10);

        // 2. Marca a lição como completa no Firebase
        await scoreProvider.completeLesson(widget.lesson.id);

        if (mounted) {
          // Retorna 'true' para avisar a tela anterior que terminou
          Navigator.of(context).pop(true);
        }
      } else {
        // --- PRÓXIMA PERGUNTA ---
        setState(() {
          _isFinishing = true; // Mostra loading no botão
        });

        // 1. Adiciona pontos pela pergunta atual (10 pontos)
        await scoreProvider.addScore(10);

        _nextQuestion();

        setState(() {
          _isFinishing = false;
        });
      }
    } catch (e) {
      _showErrorSnackBar("Erro ao salvar progresso: $e");
      if (mounted) {
        setState(() {
          _isFinishing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textDark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.lesson.title,
          style: Theme.of(context).appBarTheme.titleTextStyle ??
              TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Barra de progresso superior
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) /
                widget.lesson.questions.length,
            backgroundColor: AppColors.inputGray,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.blue),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pergunta ${_currentQuestionIndex + 1} de ${widget.lesson.questions.length}',
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentQuestion.text,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Lista de Respostas
                  ..._currentQuestion.answers
                      .map((answer) => _buildAnswerOption(answer))
                      .toList(),
                  const SizedBox(height: 40),

                  // Botão de Confirmar (Visível apenas se ainda não checou)
                  if (!_isAnswerChecked)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _checkAnswer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Confirmar Resposta',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      // BottomSheet aparece quando a resposta é verificada
      bottomSheet: _isAnswerChecked ? _buildFeedbackSheet() : null,
    );
  }

  Widget _buildAnswerOption(Answer answer) {
    bool isSelected = _selectedAnswer == answer;
    Color? tileColor;
    Color? textColor;
    Color borderColor = Colors.transparent;

    final defaultTextColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textDark;

    if (_isAnswerChecked) {
      if (answer.isCorrect) {
        tileColor = const Color(0xFF28A745).withOpacity(0.1);
        textColor = const Color(0xFF28A745);
      } else if (isSelected && !answer.isCorrect) {
        tileColor = const Color(0xFFDC3545).withOpacity(0.1);
        textColor = const Color(0xFFDC3545);
      } else {
        tileColor = AppColors.inputGray.withOpacity(0.5);
        textColor = AppColors.textLight;
      }
    } else if (isSelected) {
      tileColor = AppColors.blue.withOpacity(0.08);
      textColor = AppColors.blue;
      borderColor = AppColors.blue;
    } else {
      tileColor = Theme.of(context).cardColor;
      textColor = defaultTextColor;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: tileColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: borderColor,
          width: borderColor == Colors.transparent ? 1 : 2,
        ),
      ),
      child: ListTile(
        title: Text(
          answer.text,
          style: TextStyle(
            color: textColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: _isAnswerChecked
            ? null
            : () {
          setState(() {
            _selectedAnswer = answer;
          });
        },
      ),
    );
  }

  Widget _buildFeedbackSheet() {
    if (_selectedAnswer == null) return const SizedBox.shrink();

    final bool isCorrect = _selectedAnswer!.isCorrect;
    final String buttonText =
    _isLastQuestion ? 'Finalizar Lição' : 'Próxima Pergunta';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isCorrect ? const Color(0xFF28A745) : const Color(0xFFDC3545),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
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
            onPressed: (isCorrect && _isFinishing)
                ? null
                : () => _handleContinue(isCorrect),
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
                : Text(isCorrect ? buttonText : 'Tentar Novamente'),
          ),
        ],
      ),
    );
  }
}