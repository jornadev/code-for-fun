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
  // Paleta de Cores Vibrantes
  final Color _mainPurple = const Color(0xFF673AB7); // Deep Purple
  final Color _correctGreen = const Color(0xFF58CC02); // Verde Duolingo
  final Color _wrongRed = const Color(0xFFFF4B4B); // Vermelho Suave

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
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.grey[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(20),
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
      SnackBar(content: Text(message), backgroundColor: _wrongRed),
    );
  }

  Future<void> _handleContinue(bool isCorrect) async {
    if (!isCorrect) {
      // Se errou, reseta para tentar de novo (não avança)
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
        // --- FINALIZANDO ---
        setState(() => _isFinishing = true);

        await scoreProvider.addScore(10);
        await scoreProvider.completeLesson(widget.lesson.id);

        if (mounted) {
          _showCompletionDialog();
        }
      } else {
        // --- PRÓXIMA ---
        setState(() => _isFinishing = true);
        await scoreProvider.addScore(10);
        _nextQuestion();
        setState(() => _isFinishing = false);
      }
    } catch (e) {
      _showErrorSnackBar("Erro ao salvar: $e");
      if (mounted) setState(() => _isFinishing = false);
    }
  }

  // --- DIALOG DE VITÓRIA (COM O DUKE) ---
  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar do Duke (Placeholder Dourado ou Imagem)
                Container(
                  height: 140,
                  width: 140,
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Image.asset(
                    'assets/images/duck.png',
                    fit: BoxFit.contain,
                    // Se não tiver a imagem, o flutter mostra um espaço vazio,
                    // então coloque um Icon de fallback se quiser:
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.emoji_events_rounded, size: 60, color: Colors.amber),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Mandou Bem!',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: _mainPurple
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                Text(
                  'Você concluiu a lição e ganhou +10 XP!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _mainPurple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'CONTINUAR',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double progress = (_currentQuestionIndex + 1) / widget.lesson.questions.length;

    return Scaffold(
      backgroundColor: Colors.white, // Fundo limpo
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: Colors.grey[400], size: 32),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // Barra de progresso no topo (Grossa e arredondada)
        title: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12, // Mais grossa
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(_correctGreen), // Verde de progresso
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
                  const SizedBox(height: 10),
                  Text(
                    'Selecione a resposta correta:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pergunta Grande
                  Text(
                    _currentQuestion.text,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900, // Fonte bem pesada
                      color: Color(0xFF2B2B2B),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Lista de Opções
                  ..._currentQuestion.answers
                      .map((answer) => _buildAnswerOption(answer))
                      .toList(),
                ],
              ),
            ),
          ),

          // Botão de Verificar (Só aparece se ainda não verificou)
          if (!_isAnswerChecked)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _checkAnswer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _mainPurple, // Roxo principal
                      foregroundColor: Colors.white,
                      elevation: 0,
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
      // BottomSheet de Feedback (Sobe quando verifica)
      bottomSheet: _isAnswerChecked ? _buildFeedbackSheet() : null,
    );
  }

  Widget _buildAnswerOption(Answer answer) {
    final bool isSelected = _selectedAnswer == answer;

    // Cores Padrão (Neutro)
    Color borderColor = Colors.grey[300]!;
    Color bgColor = Colors.white;
    Color textColor = const Color(0xFF4B4B4B);
    double borderWidth = 2.0;

    // Cores de Feedback
    if (_isAnswerChecked) {
      if (isSelected) {
        if (answer.isCorrect) {
          borderColor = _correctGreen;
          bgColor = _correctGreen.withOpacity(0.1);
          textColor = _correctGreen;
        } else {
          borderColor = _wrongRed;
          bgColor = _wrongRed.withOpacity(0.1);
          textColor = _wrongRed;
        }
      } else {
        // Não selecionados ficam apagadinhos
        borderColor = Colors.grey[200]!;
        textColor = Colors.grey[400]!;
      }
    } else if (isSelected) {
      // Selecionado (Pré-verificação)
      borderColor = _mainPurple; // Borda Roxa
      bgColor = _mainPurple.withOpacity(0.08); // Fundo lilás bem claro
      textColor = _mainPurple; // Texto roxo
      borderWidth = 3.0; // Borda mais grossa
    }

    return GestureDetector(
      onTap: _isAnswerChecked ? null : () => setState(() => _selectedAnswer = answer),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: isSelected && !_isAnswerChecked
              ? [BoxShadow(color: _mainPurple.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))]
              : [],
        ),
        child: Row(
          children: [
            // Círculo indicador (A, B, C ou Check)
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isAnswerChecked && isSelected ? borderColor : Colors.grey[300]!,
                  width: 2,
                ),
                color: Colors.white,
              ),
              child: _isAnswerChecked && isSelected
                  ? Icon(
                  answer.isCorrect ? Icons.check : Icons.close,
                  size: 20,
                  color: borderColor
              )
                  : (isSelected
                  ? Center(child: Container(width: 14, height: 14, decoration: BoxDecoration(color: _mainPurple, borderRadius: BorderRadius.circular(4))))
                  : null),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                answer.text,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
    final Color statusColor = isCorrect ? _correctGreen : _wrongRed;
    final String title = isCorrect ? 'Incrível!' : 'Incorreto';
    final IconData icon = isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final String btnText = isCorrect
        ? (_isLastQuestion ? 'CONCLUIR' : 'CONTINUAR')
        : 'TENTAR NOVAMENTE';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white, // Fundo branco limpo
        border: Border(top: BorderSide(color: statusColor.withOpacity(0.1), width: 2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Linha de Status (Ícone + Texto)
            Row(
              children: [
                Icon(icon, color: statusColor, size: 32),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Botão de Ação
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (isCorrect && _isFinishing)
                    ? null
                    : () => _handleContinue(isCorrect),
                style: ElevatedButton.styleFrom(
                  backgroundColor: statusColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: (isCorrect && _isFinishing)
                    ? const SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                )
                    : Text(
                  btnText,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}