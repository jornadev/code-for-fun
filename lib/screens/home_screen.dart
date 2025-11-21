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

  final TrailService _trailService = TrailService();

  // Cor Roxa Principal (Deep Purple)
  final Color _mainPurple = const Color(0xFF673AB7);

  @override
  void initState() {
    super.initState();
    _loadUserName();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ScoreProvider>(context, listen: false).loadUserData();
    });
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

  @override
  Widget build(BuildContext context) {
    final scoreProvider = context.watch<ScoreProvider>();
    final Set<String> completedIds = scoreProvider.completedLessonIds.toSet();

    // Detecta se é modo escuro
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Cor do fundo do container (Branco no claro, Cinza escuro no escuro)
    final sheetColor = isDark ? const Color(0xFF1B1B1E) : Colors.white;

    return Scaffold(
      backgroundColor: _mainPurple, // O fundo geral é roxo (cabeçalho)
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. CABEÇALHO
          _buildHeader(context, _userName),

          // 2. CONTEÚDO (Dentro do Container que adapta a cor)
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: sheetColor, // <--- AQUI MUDA A COR
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
                          // No modo escuro o loading é branco, no claro é roxo
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

                  return SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 24, bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildContinueSection(context, completedIds, trails, isDark),
                        _buildRecommendedSection(context, trails, isDark),
                        const SizedBox(height: 24),
                        _buildYourTrailsSection(context, completedIds, trails, isDark),
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

  Widget _buildContinueSection(BuildContext context, Set<String> completedIds, List<Trail> allTrails, bool isDark) {
    Trail? trailToContinue;
    double trailProgress = 0.0;

    for (var trail in allTrails) {
      if (trail.lessonIds.isEmpty) continue;

      int completedCount = trail.lessonIds
          .where((id) => completedIds.contains(id))
          .length;

      double progress = completedCount / trail.lessonIds.length;

      if (progress > 0 && progress < 1.0) {
        trailToContinue = trail;
        trailProgress = progress;
        break;
      }
    }

    if (trailToContinue == null) {
      return const SizedBox.shrink();
    }

    // Define a cor do título baseada no tema
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

  Widget _buildRecommendedSection(BuildContext context, List<Trail> trails, bool isDark) {
    final titleColor = isDark ? Colors.white : AppColors.textDark;

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
              children: trails.map((trail) {
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

  Widget _buildYourTrailsSection(BuildContext context, Set<String> completedIds, List<Trail> trails, bool isDark) {
    final titleColor = isDark ? Colors.white : AppColors.textDark;

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
            children: trails.map((trail) {

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