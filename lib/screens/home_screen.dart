import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:code_for_fun/model/trail_model.dart';
import 'package:code_for_fun/service/trail_service.dart';
import 'package:code_for_fun/screens/trail_screen.dart';
import 'package:code_for_fun/providers/score_provider.dart';
import 'package:code_for_fun/constants/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '...';

  // Serviço para buscar dados do Firebase
  final TrailService _trailService = TrailService();

  @override
  void initState() {
    super.initState();
    _loadUserName();
    // Garante que o ScoreProvider carregue o que o usuário já fez do banco
    Provider.of<ScoreProvider>(context, listen: false).loadUserData();
  }

  void _loadUserName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null &&
        user.displayName != null &&
        user.displayName!.isNotEmpty) {
      setState(() {
        _userName = user.displayName!.toUpperCase();
      });
    } else {
      setState(() {
        _userName = 'JOGADOR';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtém a lista de lições que o usuário já completou
    final scoreProvider = context.watch<ScoreProvider>();
    final Set<String> completedIds = scoreProvider.completedLessonIds.toSet();

    final theme = Theme.of(context);
    final backgroundColor = theme.scaffoldBackgroundColor;

    return SingleChildScrollView(
      child: Container(
        color: backgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, _userName),

            // STREAM BUILDER: Ouve o Firebase em tempo real
            StreamBuilder<List<Trail>>(
              stream: _trailService.getTrailsStream(),
              builder: (context, snapshot) {
                // 1. Carregando
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                // 2. Erro
                if (snapshot.hasError) {
                  return const Center(child: Text('Erro ao carregar trilhas'));
                }

                // 3. Sucesso
                final trails = snapshot.data ?? [];

                if (trails.isEmpty) {
                  return const Center(child: Text("Nenhuma trilha encontrada."));
                }

                // Monta a tela passando as trilhas e os IDs completados para cálculo
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildContinueSection(context, completedIds, trails),
                    _buildRecommendedSection(context, trails),
                    const SizedBox(height: 24),
                    _buildYourTrailsSection(context, completedIds, trails),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // HEADER ------------------------------------------------------------------
  Widget _buildHeader(BuildContext context, String userName) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? AppColors.textDark;

    return Container(
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BEM VINDO(A), $userName',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pronto para o próximo desafio?',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: textColor.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Badge de Pontuação
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Consumer<ScoreProvider>(
              builder: (context, provider, child) {
                return Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      provider.isLoading ? '...' : provider.score.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // CONTINUE SECTION --------------------------------------------------------
  Widget _buildContinueSection(BuildContext context, Set<String> completedIds, List<Trail> allTrails) {
    Trail? trailToContinue;
    double trailProgress = 0.0;

    // Lógica para achar qual trilha continuar:
    // Procura a primeira que tenha progresso > 0% e < 100%
    for (var trail in allTrails) {
      if (trail.lessonIds.isEmpty) continue;

      // CALCULA O PROGRESSO DINAMICAMENTE
      // Conta quantos IDs da trilha estão na lista de completados do usuário
      int completedCount = trail.lessonIds
          .where((id) => completedIds.contains(id))
          .length;

      double progress = completedCount / trail.lessonIds.length;

      if (progress > 0 && progress < 1.0) {
        trailToContinue = trail;
        trailProgress = progress;
        break; // Encontrou, para de procurar
      }
    }

    // Se não tiver nenhuma em andamento, esconde a seção
    if (trailToContinue == null) {
      return const SizedBox.shrink();
    }

    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textDark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Retome de onde parou',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildProgressCard(
            context,
            trail: trailToContinue,
            progress: trailProgress,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // RECOMMENDED SECTION -----------------------------------------------------
  Widget _buildRecommendedSection(BuildContext context, List<Trail> trails) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textDark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trilhas Recomendadas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: trails.map((trail) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _buildTrailCard(context, trail: trail),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // YOUR TRAILS SECTION -----------------------------------------------------
  Widget _buildYourTrailsSection(BuildContext context, Set<String> completedIds, List<Trail> trails) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textDark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Todas as Trilhas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: trails.map((trail) {

              // CALCULA O PROGRESSO PARA CADA TRILHA
              double progress = 0.0;
              if (trail.lessonIds.isNotEmpty) {
                int completedCount = trail.lessonIds
                    .where((id) => completedIds.contains(id))
                    .length;
                progress = completedCount / trail.lessonIds.length;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildProgressCard(
                  context,
                  trail: trail,
                  progress: progress,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // CARDS -------------------------------------------------------------------
  Widget _buildProgressCard(
      BuildContext context, {
        required Trail trail,
        required double progress,
      }) {
    String percentageLabel = '${(progress * 100).toInt()}%';

    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? AppColors.textDark;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TrailScreen(trail: trail),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: trail.iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    trail.icon,
                    color: trail.iconColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trail.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Usa lessonIds.length para mostrar o total real
                      Text(
                        '${trail.lessonIds.length} Lições • ${trail.level}',
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: textColor.withOpacity(0.5),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProgressBar(context, progress, percentageLabel),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailCard(BuildContext context, {required Trail trail}) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? AppColors.textDark;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TrailScreen(trail: trail),
          ),
        );
      },
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: trail.iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                trail.icon,
                color: trail.iconColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              trail.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              trail.level,
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PROGRESS BAR ------------------------------------------------------------
  Widget _buildProgressBar(
      BuildContext context, double progress, String percentageLabel) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(
              Colors.deepPurple,
            ),
            minHeight: 16,
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Text(
              percentageLabel,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}