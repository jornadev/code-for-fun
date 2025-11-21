import 'package:flutter/material.dart';
import 'package:code_for_fun/constants/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final String? _currentUserUid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textDark;

    return Scaffold(
      // sem backgroundColor fixo, deixa o tema cuidar
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('score', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.blue,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar o ranking.\nTente novamente mais tarde.',
                textAlign: TextAlign.center,
                style: TextStyle(color: textColor),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Ainda não há pontuações no ranking.',
                style: TextStyle(color: textColor),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            children: [
              const SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  'Ranking',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              ...List.generate(docs.length, (index) {
                final data = docs[index].data() as Map<String, dynamic>;
                final bool isCurrentUser = docs[index].id == _currentUserUid;

                return _buildRankingCard(
                  context: context,
                  position: index + 1,
                  name: (data['displayName'] ?? 'Usuário Anônimo') as String,
                  score: (data['score'] ?? 0) as int,
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
    required BuildContext context,
    required int position,
    required String name,
    required int score,
    required bool isCurrentUser,
  }) {
    final cardColor = Theme.of(context).cardColor;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textDark;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: isCurrentUser ? Colors.orange.withOpacity(0.1) : cardColor,
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
            color: isCurrentUser ? Colors.orange[800] : textColor,
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
        color = Colors.grey;
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
