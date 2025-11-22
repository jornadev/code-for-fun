import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:code_for_fun/model/trail_model.dart';
import 'package:code_for_fun/providers/score_provider.dart';
import 'package:code_for_fun/service/trail_service.dart';
import 'package:code_for_fun/constants/app_colors.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  final Color _mainPurple = const Color(0xFF673AB7);
  final int _xpPerLesson = 50;

  bool _isTrailCompleted(Trail trail, Set<String> completedIds) {
    if (trail.lessonIds.isEmpty) {
      return false;
    }
    return trail.lessonIds.every(completedIds.contains);
  }

  void _showAchievementDetails(BuildContext context, Trail trail) {
    final int totalXPGained = trail.lessonIds.length * _xpPerLesson;

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final dialogColor = isDark ? const Color(0xFF2A2A2D) : Colors.white;
        final textColor = isDark ? Colors.white : AppColors.textDark;

        return AlertDialog(
          backgroundColor: dialogColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: _mainPurple,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.workspace_premium_rounded,
                      color: Colors.amber,
                      size: 50,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${trail.title}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      icon: Icons.check_circle_rounded,
                      label: 'Status:',
                      value: 'Concluída (100%)',
                      color: _mainPurple,
                      textColor: textColor,
                    ),
                    _buildDetailRow(
                      icon: Icons.leaderboard_rounded,
                      label: 'Nível da Trilha:',
                      value: trail.level,
                      color: Colors.orange,
                      textColor: textColor,
                    ),
                    _buildDetailRow(
                      icon: Icons.layers_rounded,
                      label: 'Total de Módulos:',
                      value: '${trail.lessonIds.length}',
                      color: Colors.blue,
                      textColor: textColor,
                    ),
                    const Divider(height: 30),
                    _buildDetailRow(
                      icon: Icons.military_tech_rounded,
                      label: 'Recompensa de XP:',
                      value: '+$totalXPGained XP',
                      color: Colors.amber,
                      textColor: textColor,
                      isBold: true,
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _mainPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Fechar', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color textColor,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: textColor.withOpacity(0.7),
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: isBold ? color : textColor,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scoreProvider = context.watch<ScoreProvider>();
    final Set<String> completedIds = scoreProvider.completedLessonIds.toSet();

    final TrailService trailService = TrailService();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textDark;

    final listContainerColor = isDark ? const Color(0xFF1B1B1E) : Colors.white;

    return Scaffold(
      backgroundColor: _mainPurple,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 30, bottom: 30),
              child: Text(
                'Suas Conquistas',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: listContainerColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: StreamBuilder<List<Trail>>(
                stream: trailService.getTrailsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: _mainPurple));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Erro ao carregar trilhas.', style: TextStyle(color: textColor)));
                  }

                  final allTrails = snapshot.data ?? [];

                  final completedTrails = allTrails.where((trail) {
                    return _isTrailCompleted(trail, completedIds);
                  }).toList();

                  if (completedTrails.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Text(
                          'Complete uma trilha para liberar seu primeiro troféu! \n\nVocê está pronto para o desafio!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 16),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 25, 24, 40),
                    itemCount: completedTrails.length,
                    itemBuilder: (context, index) {
                      final trail = completedTrails[index];
                      return _buildCompletedCard(context, trail, isDark);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedCard(BuildContext context, Trail trail, bool isDark) {
    final cardColor = isDark ? const Color(0xFF2A2A2D) : Colors.white;
    final titleColor = isDark ? Colors.white : AppColors.textDark;

    return GestureDetector(
      onTap: () => _showAchievementDetails(context, trail),
      child: Card(
        color: cardColor,
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.amber.withOpacity(0.5), width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(
                Icons.workspace_premium_rounded,
                color: Colors.amber,
                size: 40,
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Trilha Concluída!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      trail.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Você dominou ${trail.lessonIds.length} módulos.',
                      style: TextStyle(
                        color: titleColor.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(Icons.chevron_right, color: titleColor.withOpacity(0.5), size: 24),
            ],
          ),
        ),
      ),
    );
  }
}