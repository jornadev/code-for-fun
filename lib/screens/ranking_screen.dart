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

  // Cor Roxa Principal (A mesma usada na TrailScreen para lições completas)
  final Color _mainPurple = const Color(0xFF8E24AA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _mainPurple,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('score', descending: true)
            .limit(50)
            .snapshots(),
        builder: (context, snapshot) {
          // 1. Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          // 2. Erro
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar ranking.',
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          // 3. Vazio
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'Ninguém jogou ainda.\nSeja o primeiro!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

          // Lógica de Separação (Pódio vs Lista)
          List<QueryDocumentSnapshot> top3 = [];
          List<QueryDocumentSnapshot> others = [];

          if (docs.length > 0) top3.add(docs[0]); // 1º
          if (docs.length > 1) top3.add(docs[1]); // 2º
          if (docs.length > 2) top3.add(docs[2]); // 3º

          // Todo mundo a partir do 4º lugar vai para a lista
          if (docs.length > 3) {
            others = docs.sublist(3);
          }

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

              // --- LISTA DE USUÁRIOS (CARD BRANCO) ---
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: others.isEmpty
                      ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        docs.length <= 3
                            ? "Chegue ao topo para aparecer aqui!"
                            : "Fim da lista",
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                    itemCount: others.length,
                    itemBuilder: (context, index) {
                      // Calcula a posição real (Índice da lista + 4, pois 1,2,3 já foram)
                      return _buildListItem(context, others[index], index + 4);
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

  // --- PÓDIO (TOP 3) ---
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

        // 1º Lugar (Centro - Maior)
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

    // Pega a inicial do nome para o avatar
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Coroa no 1º lugar
        if (isFirst)
          const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 32),

        const SizedBox(height: 8),

        // Avatar Circular
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
                color: _mainPurple, // Letra roxa para combinar
                fontWeight: FontWeight.bold,
                fontSize: isFirst ? 24 : 18,
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Nome
        Text(
          name.split(' ').first, // Só o primeiro nome
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          overflow: TextOverflow.ellipsis,
        ),

        // Pontos
        Text(
          '$score pts',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 8),

        // Barra do Pódio
        Container(
          width: double.infinity,
          height: height * 0.4,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3), // Transparente para ficar sutil
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

  // --- ITEM DA LISTA (4º lugar em diante) ---
  Widget _buildListItem(BuildContext context, QueryDocumentSnapshot doc, int position) {
    final data = doc.data() as Map<String, dynamic>;
    final bool isCurrentUser = doc.id == _currentUserUid;

    final String name = data['displayName']?.toString() ?? 'Anônimo';
    final int score = (data['score'] as num?)?.toInt() ?? 0;
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        // Se for o usuário atual, destaca com um roxo bem clarinho
        color: isCurrentUser ? _mainPurple.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isCurrentUser
            ? Border.all(color: _mainPurple, width: 1.5)
            : Border.all(color: Colors.grey.shade200),
        boxShadow: [
          if (!isCurrentUser)
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Posição (#4, #5...)
            SizedBox(
              width: 30,
              child: Text(
                '$position',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Avatar Pequeno
            CircleAvatar(
              radius: 22,
              backgroundColor: _mainPurple.withOpacity(0.1),
              child: Text(
                initial,
                style: TextStyle(
                  color: _mainPurple,
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
            color: isCurrentUser ? _mainPurple : AppColors.textDark,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.inputGray,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$score pts',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }
}