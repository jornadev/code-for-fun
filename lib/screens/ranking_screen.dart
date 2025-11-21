import 'dart:convert';
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

  // Cores da Identidade Visual
  final Color _mainPurple = const Color(0xFF673AB7); // Roxo Principal
  final Color _accentPurple = const Color(0xFF512DA8); // Roxo Escuro para degradê

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Cores adaptáveis para o container da lista
    final sheetColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F7);

    return Scaffold(
      // Fundo com degradê sutil para ficar mais "premium"
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_mainPurple, _accentPurple],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .orderBy('score', descending: true)
              .limit(50)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'Erro ao carregar ranking.',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            final docs = snapshot.data?.docs ?? [];

            if (docs.isEmpty) {
              return const Center(
                child: Text(
                  'Ninguém jogou ainda.\nSeja o primeiro!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              );
            }

            // Separa Top 3
            List<QueryDocumentSnapshot> top3 = [];
            if (docs.length > 0) top3.add(docs[0]);
            if (docs.length > 1) top3.add(docs[1]);
            if (docs.length > 2) top3.add(docs[2]);

            return Column(
              children: [
                // --- CABEÇALHO E PÓDIO ---
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
                    child: Column(
                      children: [
                        const Text(
                          'Ranking Global',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800, // Fonte mais grossa
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildPodium(context, top3),
                      ],
                    ),
                  ),
                ),

                // --- LISTA DE USUÁRIOS ---
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: sheetColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    // ClipRRect garante que o conteúdo não vase nas bordas arredondadas
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 25, 20, 40),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          return _buildListItem(context, docs[index], index + 1, isDark);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
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
        // 2º Lugar (Esquerda)
        if (top3.length > 1)
          Expanded(
            child: _buildPodiumItem(
              doc: top3[1],
              position: 2,
              height: 130,
              color: const Color(0xFFE0E0E0), // Prata Brilhante
              scoreColor: Colors.white70,
            ),
          )
        else
          const Spacer(),

        // 1º Lugar (Centro)
        Expanded(
          flex: 2, // Ocupa mais espaço horizontal
          child: _buildPodiumItem(
            doc: top3[0],
            position: 1,
            height: 170, // Mais alto
            color: const Color(0xFFFFD700), // Ouro Vibrante
            scoreColor: const Color(0xFFFFD700),
            isFirst: true,
          ),
        ),

        // 3º Lugar (Direita)
        if (top3.length > 2)
          Expanded(
            child: _buildPodiumItem(
              doc: top3[2],
              position: 3,
              height: 110,
              color: const Color(0xFFCD7F32), // Bronze Avermelhado
              scoreColor: const Color(0xFFCD7F32).withOpacity(0.8),
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
    required Color scoreColor,
    bool isFirst = false,
  }) {
    final data = doc.data() as Map<String, dynamic>;
    final String name = data['displayName']?.toString() ?? 'Anônimo';
    final int score = (data['score'] as num?)?.toInt() ?? 0;
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    // Foto Base64
    ImageProvider? avatarImage;
    final String? base64String = data['photoBase64'];
    if (base64String != null && base64String.isNotEmpty) {
      try {
        avatarImage = MemoryImage(base64Decode(base64String));
      } catch (_) {}
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Coroa Flutuante
        if (isFirst)
          Transform.translate(
            offset: const Offset(0, 10),
            child: const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 40),
          ),

        const SizedBox(height: 4),

        // Avatar com Borda Dupla (Branco + Cor do Rank)
        Container(
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 3), // Borda colorida externa
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ]
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2), // Borda branca interna
            ),
            child: CircleAvatar(
              radius: isFirst ? 36 : 26,
              backgroundColor: Colors.white,
              backgroundImage: avatarImage,
              child: avatarImage == null
                  ? Text(
                initial,
                style: TextStyle(
                  color: _mainPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: isFirst ? 24 : 18,
                ),
              )
                  : null,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Nome Curto
        Text(
          name.split(' ').first,
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
            color: isFirst ? const Color(0xFFFFE082) : Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 8),

        // Barra do Pódio com Gradiente
        Container(
          width: double.infinity,
          height: height * 0.45,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withOpacity(0.4), // Mais visível no topo
                color.withOpacity(0.0), // Desaparece embaixo
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            border: Border(
              top: BorderSide(color: color, width: 4), // Topo sólido
              left: BorderSide(color: color.withOpacity(0.3), width: 1),
              right: BorderSide(color: color.withOpacity(0.3), width: 1),
            ),
          ),
          child: Center(
            child: Text(
              '$position',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w900,
                fontFamily: 'Roboto', // Fonte padrão, mas bold
                shadows: [
                  Shadow(blurRadius: 15, color: color, offset: const Offset(0, 0))
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- ITEM DA LISTA ---
  Widget _buildListItem(BuildContext context, QueryDocumentSnapshot doc, int position, bool isDark) {
    final data = doc.data() as Map<String, dynamic>;
    final bool isCurrentUser = doc.id == _currentUserUid;

    final String name = data['displayName']?.toString() ?? 'Anônimo';
    final int score = (data['score'] as num?)?.toInt() ?? 0;
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    // Foto
    ImageProvider? avatarImage;
    final String? base64String = data['photoBase64'];
    if (base64String != null && base64String.isNotEmpty) {
      try {
        avatarImage = MemoryImage(base64Decode(base64String));
      } catch (_) {}
    }

    // Cores de Troféu para os Top 3 na lista
    Widget rankWidget;
    if (position == 1) {
      rankWidget = const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 28);
    } else if (position == 2) {
      rankWidget = const Icon(Icons.emoji_events, color: Color(0xFFC0C0C0), size: 28);
    } else if (position == 3) {
      rankWidget = const Icon(Icons.emoji_events, color: Color(0xFFCD7F32), size: 28);
    } else {
      rankWidget = SizedBox(
        width: 28,
        child: Text(
          '$position',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      );
    }

    // Cores do Card
    final cardColor = isDark
        ? (isCurrentUser ? const Color(0xFF311B92) : const Color(0xFF2C2C2C))
        : (isCurrentUser ? _mainPurple.withOpacity(0.08) : Colors.white);

    final textColor = isCurrentUser
        ? (isDark ? const Color(0xFFB39DDB) : _mainPurple)
        : (isDark ? Colors.white : AppColors.textDark);

    final borderColor = isCurrentUser
        ? (isDark ? const Color(0xFF7E57C2) : _mainPurple.withOpacity(0.5))
        : Colors.transparent;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: borderColor,
            width: isCurrentUser ? 1.5 : 0.0
        ),
        boxShadow: [
          if (!isDark) // Sombra só no modo claro
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        children: [
          // 1. Posição / Troféu
          SizedBox(width: 30, child: Center(child: rankWidget)),

          const SizedBox(width: 12),

          // 2. Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: isDark ? _mainPurple.withOpacity(0.4) : _mainPurple.withOpacity(0.1),
            backgroundImage: avatarImage,
            child: avatarImage == null
                ? Text(
              initial,
              style: TextStyle(
                color: isDark ? Colors.white : _mainPurple,
                fontWeight: FontWeight.bold,
              ),
            )
                : null,
          ),

          const SizedBox(width: 16),

          // 3. Nome
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: textColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // 4. Pontos (Pill)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? Colors.black26 : AppColors.inputGray,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$score pts',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: isDark ? Colors.white70 : AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}