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

  // Cor Roxa Principal
  final Color _mainPurple = const Color(0xFF673AB7);

  @override
  Widget build(BuildContext context) {
    // 1. DETECTA O TEMA
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 2. DEFINE AS CORES COM BASE NO TEMA
    // Fundo da lista: Branco no modo claro, Cinza escuro no modo noturno
    final sheetColor = isDark ? const Color(0xFF1B1B1E) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textDark;

    return Scaffold(
      backgroundColor: _mainPurple, // O fundo do topo continua Roxo (Identidade do app)
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('score', descending: true)
            .limit(50)
            .snapshots(),
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          // Erro
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar ranking.',
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          // Vazio
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'Ninguém jogou ainda.\nSeja o primeiro!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

          // Separa os Top 3 para o Pódio
          List<QueryDocumentSnapshot> top3 = [];
          if (docs.length > 0) top3.add(docs[0]);
          if (docs.length > 1) top3.add(docs[1]);
          if (docs.length > 2) top3.add(docs[2]);

          return Column(
            children: [
              // --- PÓDIO (FUNDO ROXO) ---
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    children: [
                      const Text(
                        'Ranking Global',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildPodium(context, top3),
                    ],
                  ),
                ),
              ),

              // --- LISTA DE USUÁRIOS (ADAPTÁVEL) ---
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: sheetColor, // <--- Cor adaptável (Branco ou Dark)
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                    itemCount: docs.length, // Mostra TODOS os usuários
                    itemBuilder: (context, index) {
                      // Passamos 'isDark' para pintar o card corretamente
                      return _buildListItem(context, docs[index], index + 1, isDark);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- WIDGETS DO PÓDIO ---
  Widget _buildPodium(BuildContext context, List<QueryDocumentSnapshot> top3) {
    if (top3.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 2º Lugar
        if (top3.length > 1)
          Expanded(
            child: _buildPodiumItem(
              doc: top3[1],
              position: 2,
              height: 130,
              color: const Color(0xFFC0C0C0), // Prata
            ),
          )
        else
          const Spacer(),

        // 1º Lugar
        Expanded(
          flex: 2,
          child: _buildPodiumItem(
            doc: top3[0],
            position: 1,
            height: 160,
            color: const Color(0xFFFFD700), // Ouro
            isFirst: true,
          ),
        ),

        // 3º Lugar
        if (top3.length > 2)
          Expanded(
            child: _buildPodiumItem(
              doc: top3[2],
              position: 3,
              height: 110,
              color: const Color(0xFFCD7F32), // Bronze
            ),
          )
        else
          const Spacer(),
      ],
    );
  }

  Widget _buildPodiumItem({
    required QueryDocumentSnapshot doc,
    required int position,
    required double height,
    required Color color,
    bool isFirst = false,
  }) {
    final data = doc.data() as Map<String, dynamic>;
    final String name = data['displayName']?.toString() ?? 'Anônimo';
    final int score = (data['score'] as num?)?.toInt() ?? 0;
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isFirst)
          const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 32),

        const SizedBox(height: 8),

        Container(
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ]
          ),
          child: CircleAvatar(
            radius: isFirst ? 32 : 22,
            backgroundColor: Colors.white,
            child: Text(
              initial,
              style: TextStyle(
                color: _mainPurple,
                fontWeight: FontWeight.bold,
                fontSize: isFirst ? 24 : 18,
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          name.split(' ').first,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          overflow: TextOverflow.ellipsis,
        ),

        Text(
          '$score pts',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 8),

        Container(
          width: double.infinity,
          height: height * 0.4,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            border: Border(top: BorderSide(color: color, width: 4)),
          ),
          child: Center(
            child: Text(
              '$position',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(blurRadius: 10, color: color, offset: const Offset(0, 0))
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- ITEM DA LISTA (ADAPTADO PARA DARK MODE) ---
  Widget _buildListItem(BuildContext context, QueryDocumentSnapshot doc, int position, bool isDark) {
    final data = doc.data() as Map<String, dynamic>;
    final bool isCurrentUser = doc.id == _currentUserUid;

    final String name = data['displayName']?.toString() ?? 'Anônimo';
    final int score = (data['score'] as num?)?.toInt() ?? 0;
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    // Cor do número da posição
    Color positionColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    if (position == 1) positionColor = const Color(0xFFFFD700);
    if (position == 2) positionColor = const Color(0xFFC0C0C0);
    if (position == 3) positionColor = const Color(0xFFCD7F32);

    // CORES ADAPTÁVEIS DO CARD
    final cardColor = isDark
        ? (isCurrentUser ? const Color(0xFF311B92) : const Color(0xFF2A2A2D))
        : (isCurrentUser ? _mainPurple.withOpacity(0.05) : Colors.white);

    final textColor = isCurrentUser
        ? (isDark ? const Color(0xFFB39DDB) : _mainPurple)
        : (isDark ? Colors.white : AppColors.textDark);

    final borderColor = isCurrentUser
        ? (isDark ? const Color(0xFF7E57C2) : _mainPurple)
        : (isDark ? Colors.white10 : Colors.grey.shade200);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: isCurrentUser ? 1.5 : 1.0),
        boxShadow: [
          if (!isCurrentUser)
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Posição
            SizedBox(
              width: 30,
              child: Text(
                '$position',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: positionColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Avatar
            CircleAvatar(
              radius: 22,
              backgroundColor: isDark ? _mainPurple.withOpacity(0.4) : _mainPurple.withOpacity(0.1),
              child: Text(
                initial,
                style: TextStyle(
                  color: isDark ? Colors.white : _mainPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : AppColors.inputGray,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$score pts',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isDark ? Colors.white70 : AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }
}