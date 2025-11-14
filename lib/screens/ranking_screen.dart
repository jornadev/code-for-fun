import 'package:flutter/material.dart';
import 'package:code_for_fun/service/user_service.dart';
import 'package:code_for_fun/constants/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final UserService _userService = UserService();
  late Future<List<Map<String, dynamic>>> _rankingFuture;
  final String? _currentUserUid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _rankingFuture = _userService.getRanking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _rankingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar o ranking.\nTente novamente mais tarde.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textDark),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Ainda não há pontuações no ranking.',
                style: TextStyle(color: AppColors.textDark),
              ),
            );
          }

          final rankingList = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            children: [
              const SizedBox(height: 60),
              const Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: Text(
                  'Ranking',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              ...List.generate(rankingList.length, (index) {
                final user = rankingList[index];
                final bool isCurrentUser = user['uid'] == _currentUserUid;

                return _buildRankingCard(
                  position: index + 1,
                  name: user['displayName'] ?? 'Usuário Anônimo',
                  score: user['score'] ?? 0,
                  isCurrentUser: isCurrentUser,
                );
              }),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRankingCard({
    required int position,
    required String name,
    required int score,
    required bool isCurrentUser,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: isCurrentUser ? Colors.orange.withOpacity(0.1) : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCurrentUser ? Colors.orange : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: ListTile(
        leading: _buildPositionIcon(position),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isCurrentUser ? Colors.orange[800] : AppColors.textDark,
          ),
        ),
        trailing: Text(
          '$score pts',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.orange,
          ),
        ),
      ),
    );
  }

  Widget _buildPositionIcon(int position) {
    IconData icon;
    Color color;

    switch (position) {
      case 1:
        icon = Icons.emoji_events;
        color = Colors.amber;
        break;
      case 2:
        icon = Icons.emoji_events;
        color = Colors.grey[600]!;
        break;
      case 3:
        icon = Icons.emoji_events;
        color = const Color(0xFFCD7F32);
        break;
      default:
        return CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.inputGray,
          child: Text(
            '$position',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
          ),
        );
    }

    return Icon(icon, color: color, size: 36);
  }
}