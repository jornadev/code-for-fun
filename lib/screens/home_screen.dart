import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:code_for_fun/model/trail_model.dart';
import 'package:code_for_fun/service/trail_service.dart';
import 'package:code_for_fun/service/user_service.dart'; // NOVO: Para buscar o último ID
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

  final TrailService _trailService = TrailService();
  final UserService _userService = UserService(); // Instância do UserService

  // Variável para guardar o ID da última trilha visitada
  String? _lastVisitedTrailId;

  // Cor Roxa Principal (Deep Purple)
  final Color _mainPurple = const Color(0xFF673AB7);

  @override
  void initState() {
    super.initState();
    _loadUserName();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ScoreProvider>(context, listen: false).loadUserData();
      _loadLastVisitedTrail(); // NOVO: Carrega a última trilha
    });
  }

  // NOVO MÉTODO: Carrega o último ID salvo
  Future<void> _loadLastVisitedTrail() async {
    final id = await _userService.getLastVisitedTrail();
    if (mounted && id != null) {
      setState(() {
        _lastVisitedTrailId = id;
      });
    }
  }

  void _loadUserName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null &&
        user.displayName != null &&
        user.displayName!.isNotEmpty) {

      final fullName = user.displayName!;
      final firstName = fullName.split(' ')[0];

      final formattedName = firstName.length > 1
          ? firstName[0].toUpperCase() + firstName.substring(1).toLowerCase()
          : firstName.toUpperCase();

      setState(() {
        _userName = formattedName;
      });
    } else {
      setState(() {
        _userName = 'Jogador';
      });
    }
  }

  // --- FUNÇÃO AUXILIAR PARA VERIFICAR CONCLUSÃO ---
  bool _isTrailCompleted(Trail trail, Set<String> completedIds) {
    if (trail.lessonIds.isEmpty) {
      return false;
    }
    // Retorna true se a contagem de lições completas for igual ao total de lições da trilha
    final int completedCount = trail.lessonIds.where((lessonId) => completedIds.contains(lessonId)).length;
    return completedCount == trail.lessonIds.length;
  }

  // --- CÁLCULO DO PROGRESSO DE UMA TRILHA ---
  double _calculateProgress(Trail trail, Set<String> completedIds) {
    if (trail.lessonIds.isEmpty) return 0.0;
    int completedCount = trail.lessonIds
        .where((lessonId) => completedIds.contains(lessonId))
        .length;
    return completedCount / trail.lessonIds.length;
  }


  @override
  Widget build(BuildContext context) {
    final scoreProvider = context.watch<ScoreProvider>();
    final Set<String> completedIds = scoreProvider.completedLessonIds.toSet();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetColor = isDark ? const Color(0xFF1B1B1E) : Colors.white;

    return Scaffold(
      backgroundColor: _mainPurple,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, _userName),

          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: sheetColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: StreamBuilder<List<Trail>>(
                stream: _trailService.getTrailsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(
                          color: isDark ? Colors.white : _mainPurple,
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Erro ao carregar trilhas',
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      ),
                    );
                  }

                  final trails = snapshot.data ?? [];

                  if (trails.isEmpty) {
                    return Center(
                      child: Text(
                        "Nenhuma trilha encontrada.",
                        style: TextStyle(color: isDark ? Colors.white70 : Colors.grey),
                      ),
                    );
                  }

                  // FILTRO PRINCIPAL: Remove trilhas 100% concluídas
                  final activeTrails = trails.where((trail) => !_isTrailCompleted(trail, completedIds)).toList();

                  return SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 24, bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // NOVO: Lógica de Continuação com Prioridade para a Última Visitada
                        _buildContinueSection(context, completedIds, activeTrails, isDark, _lastVisitedTrailId),
                        _buildRecommendedSection(context, activeTrails, isDark, completedIds),
                        const SizedBox(height: 24),
                        _buildYourTrailsSection(context, completedIds, activeTrails, isDark),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String userName) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Olá, $userName! 👋',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pronto para codar hoje?',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
              ),
              child: Consumer<ScoreProvider>(
                builder: (context, provider, child) {
                  return Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 24),
                      const SizedBox(width: 6),
                      Text(
                        provider.isLoading ? '...' : provider.score.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueSection(BuildContext context, Set<String> completedIds, List<Trail> activeTrails, bool isDark, String? lastVisitedId) {
    Trail? trailToContinue;
    double trailProgress = 0.0;

    // 1. Prioridade: Última trilha visitada, SE ela tiver progresso e não estiver completa
    if (lastVisitedId != null) {
      // CORREÇÃO: Usar where().isNotEmpty para evitar o erro de firstWhereOrNull/firstWhere sem orElse
      final foundTrail = activeTrails.where((t) => t.id == lastVisitedId);

      if (foundTrail.isNotEmpty) {
        final lastTrail = foundTrail.first; // Seguro para pegar o primeiro
        final progress = _calculateProgress(lastTrail, completedIds);

        // Verifica se tem progresso (0% < progress < 100%)
        if (progress > 0 && progress < 1.0) {
          trailToContinue = lastTrail;
          trailProgress = progress;
        }
      }
    }

    // 2. Fallback: Se a última visitada não serviu, pegamos a primeira com progresso
    if (trailToContinue == null) {
      for (var trail in activeTrails) {
        final progress = _calculateProgress(trail, completedIds);
        if (progress > 0 && progress < 1.0) {
          trailToContinue = trail;
          trailProgress = progress;
          break;
        }
      }
    }

    if (trailToContinue == null) {
      return const SizedBox.shrink();
    }

    final titleColor = isDark ? Colors.white : AppColors.textDark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Continue aprendendo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildProgressCard(
            context,
            trail: trailToContinue,
            progress: trailProgress,
            isDark: isDark,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildRecommendedSection(BuildContext context, List<Trail> activeTrails, bool isDark, Set<String> completedIds) {
    final titleColor = isDark ? Colors.white : AppColors.textDark;

    final recommended = activeTrails.where((t) {
      final progress = _calculateProgress(t, completedIds);
      return progress < 0.1;
    }).toList();


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sugestões para você',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: recommended.map((trail) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _buildTrailCard(context, trail: trail, isDark: isDark),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYourTrailsSection(BuildContext context, Set<String> completedIds, List<Trail> activeTrails, bool isDark) {
    final titleColor = isDark ? Colors.white : AppColors.textDark;

    if (activeTrails.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Parabéns!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Você concluiu todas as trilhas disponíveis. Ótimo trabalho!',
              style: TextStyle(
                fontSize: 16,
                color: titleColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    }


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explorar Trilhas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: activeTrails.map((trail) {

              double progress = _calculateProgress(trail, completedIds);

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildProgressCard(
                  context,
                  trail: trail,
                  progress: progress,
                  isDark: isDark,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(
      BuildContext context, {
        required Trail trail,
        required double progress,
        required bool isDark,
      }) {
    String percentageLabel = '${(progress * 100).toInt()}%';

    // Cores do Card no modo escuro/claro
    final cardColor = isDark ? const Color(0xFF2A2A2D) : Colors.white;
    final borderColor = isDark ? Colors.white10 : Colors.grey.shade100;
    final titleColor = isDark ? Colors.white : AppColors.textDark;
    final subTitleColor = isDark ? Colors.white70 : AppColors.textDark.withOpacity(0.6);

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
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
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
                    color: _mainPurple.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    trail.icon,
                    // No modo escuro, um roxo mais claro (lilás) fica melhor para contraste
                    color: isDark ? const Color(0xFFB39DDB) : _mainPurple,
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
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${trail.lessonIds.length} Lições • ${trail.level}',
                        style: TextStyle(
                          color: subTitleColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? Colors.white30 : Colors.grey[400],
                  size: 28,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProgressBar(context, progress, percentageLabel, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailCard(BuildContext context, {required Trail trail, required bool isDark}) {
    final cardColor = isDark ? const Color(0xFF2A2A2D) : Colors.white;
    final borderColor = isDark ? Colors.white10 : Colors.grey.shade100;
    final titleColor = isDark ? Colors.white : AppColors.textDark;
    final subTitleColor = isDark ? Colors.white70 : AppColors.textDark.withOpacity(0.6);

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
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: trail.iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                trail.icon,
                color: trail.iconColor, // Mantém a cor original do ícone da trilha
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              trail.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              trail.level,
              style: TextStyle(
                color: subTitleColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(
      BuildContext context, double progress, String percentageLabel, bool isDark) {

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            // Fundo da barra mais escuro no modo dark
            backgroundColor: isDark ? Colors.grey[700] : Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              isDark ? const Color(0xFFB39DDB) : _mainPurple, // Lilás no dark, Roxo no light
            ),
            minHeight: 18,
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Text(
              percentageLabel,
              style: TextStyle(
                // Texto preto se a barra for muito clara (lilás), branco se for escura
                color: isDark ? Colors.black87 : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}