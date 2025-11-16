import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:code_for_fun/providers/score_provider.dart';
import 'package:code_for_fun/constants/app_colors.dart';
import 'package:code_for_fun/service/trail_service.dart';
import 'package:code_for_fun/model/trail_model.dart';
import 'package:code_for_fun/screens/trail_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String userName = user?.displayName ?? 'Usuário Anônimo';
    final String userEmail = user?.email ?? 'email@nao-encontrado.com';

    final scoreProvider = context.watch<ScoreProvider>();
    final Set<String> completedLessonIds =
    scoreProvider.completedLessonIds.toSet();

    final List<Trail> allTrails = TrailService.getRecommendedTrails();

    final List<Trail> inProgressTrails = allTrails.where((trail) {
      if (trail.lessons.isEmpty) return false;

      final int completedCount = trail.lessons
          .where((l) => completedLessonIds.contains(l.id))
          .length;

      final double progress = completedCount / trail.lessons.length;

      return progress > 0 && progress < 1;
    }).toList();

    final int score = scoreProvider.score;
    String userLevel;
    IconData levelIcon;

    if (score <= 250) {
      userLevel = 'Iniciante';
      levelIcon = Icons.shield_outlined;
    } else if (score <= 500) {
      userLevel = 'Aprendiz';
      levelIcon = Icons.military_tech_outlined;
    } else if (score <= 750) {
      userLevel = 'Avançado';
      levelIcon = Icons.verified_user_outlined;
    } else {
      userLevel = 'Mestre';
      levelIcon = Icons.workspace_premium_outlined;
    }

    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textDark;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      children: [
        const SizedBox(height: 60),
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Text(
            'Meu Perfil',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        Center(
          child: CircleAvatar(
            radius: 60,
            backgroundColor: Colors.orange.withOpacity(0.1),
            child: const Icon(
              Icons.person,
              size: 80,
              color: Colors.orange,
            ),
          ),
        ),
        const SizedBox(height: 40),

        // Nome
        _buildInfoTile(
          context: context,
          icon: Icons.person_outlined,
          label: 'Nome',
          value: userName,
        ),

        // Email
        _buildInfoTile(
          context: context,
          icon: Icons.email_outlined,
          label: 'E-mail',
          value: userEmail,
        ),

        // Pontuação total
        Consumer<ScoreProvider>(
          builder: (context, provider, child) {
            return _buildInfoTile(
              context: context,
              icon: Icons.star_outlined,
              label: 'Pontuação Total',
              value: provider.isLoading
                  ? 'Carregando...'
                  : provider.score.toString(),
            );
          },
        ),

        // Nível atual
        _buildInfoTile(
          context: context,
          icon: levelIcon,
          label: 'Nível Atual',
          value: scoreProvider.isLoading ? 'Calculando...' : userLevel,
        ),

        const SizedBox(height: 24),
        _buildInProgressSection(context, inProgressTrails),
        const SizedBox(height: 24),
      ],
    );
  }

  // -------------------------------------------------------------------------
  /// Cursos em andamento
  Widget _buildInProgressSection(
      BuildContext context, List<Trail> inProgressTrails) {
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cursos em Andamento',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        if (inProgressTrails.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Nenhum curso em andamento.',
                style: TextStyle(
                  color: textColor.withOpacity(0.6),
                  fontSize: 16,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            itemCount: inProgressTrails.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final trail = inProgressTrails[index];
              final int completedCount = trail.lessons
                  .where((l) => context
                  .read<ScoreProvider>()
                  .completedLessonIds
                  .contains(l.id))
                  .length;
              final double progress =
              (completedCount > 0 && trail.lessons.isNotEmpty)
                  ? (completedCount / trail.lessons.length)
                  : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildProgressCard(
                  context,
                  trail: trail,
                  progress: progress,
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildProgressCard(
      BuildContext context, {
        required Trail trail,
        required double progress,
      }) {
    String percentageLabel = '${(progress * 100).toInt()}%';

    final theme = Theme.of(context);
    final textColor =
        theme.textTheme.bodyLarge?.color ?? AppColors.textDark;
    final isDark = theme.brightness == Brightness.dark;

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
                      Text(
                        '${trail.lessons.length} Lições • ${trail.level}',
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
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor:
                    isDark ? Colors.grey[800] : Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.orange,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final textColor =
        theme.textTheme.bodyLarge?.color ?? AppColors.textDark;

    return Card(
      elevation: 2,
      shadowColor: AppColors.shadowColor.withOpacity(0.1),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon, color: Colors.orange, size: 28),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: textColor.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
