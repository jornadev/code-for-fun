import 'dart:convert'; // Para decodificar a imagem Base64
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart'; // Pacote de imagem
import 'package:cloud_firestore/cloud_firestore.dart'; // Para ouvir o banco

import 'package:code_for_fun/providers/score_provider.dart';
import 'package:code_for_fun/constants/app_colors.dart';
import 'package:code_for_fun/service/trail_service.dart';
import 'package:code_for_fun/service/user_service.dart';
import 'package:code_for_fun/model/trail_model.dart';
import 'package:code_for_fun/screens/trail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TrailService _trailService = TrailService();
  final UserService _userService = UserService();
  final Color _mainPurple = const Color(0xFF673AB7);

  bool _isUploading = false;

  Future<void> _pickAndSaveImage() async {
    final picker = ImagePicker();

    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 60,
      );

      if (pickedFile != null) {
        setState(() => _isUploading = true);

        File file = File(pickedFile.path);
        await _userService.saveProfileImage(file);

        if (mounted) {
          setState(() => _isUploading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto de perfil atualizada!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      print("Erro ao selecionar imagem: $e");
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String userName = user?.displayName ?? 'Usuário Anônimo';
    final String userEmail = user?.email ?? 'email@nao-encontrado.com';

    final scoreProvider = context.watch<ScoreProvider>();
    final Set<String> completedIds = scoreProvider.completedLessonIds.toSet();
    final int score = scoreProvider.score;

    // Detecção de Tema
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetColor = isDark ? const Color(0xFF1B1B1E) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textDark;

    String userLevel;
    IconData levelIcon;
    if (score <= 250) {
      userLevel = 'Iniciante'; levelIcon = Icons.shield_outlined;
    } else if (score <= 500) {
      userLevel = 'Aprendiz'; levelIcon = Icons.military_tech_outlined;
    } else if (score <= 750) {
      userLevel = 'Avançado'; levelIcon = Icons.verified_user_outlined;
    } else {
      userLevel = 'Mestre'; levelIcon = Icons.workspace_premium_outlined;
    }

    return Scaffold(
      backgroundColor: _mainPurple, // Fundo Roxo no topo
      body: Column(
        children: [
          // --- CABEÇALHO ROXO COM AVATAR ---
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 30),
              child: Column(
                children: [
                  const Text(
                    'Meu Perfil',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Avatar com Anel
                  Center(
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: _isUploading ? null : _pickAndSaveImage,
                          child: StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(user?.uid)
                                .snapshots(),
                            builder: (context, snapshot) {
                              ImageProvider? imageProvider;

                              if (snapshot.hasData && snapshot.data!.exists) {
                                final data = snapshot.data!.data() as Map<String, dynamic>?;
                                final String? base64String = data?['photoBase64'];

                                if (base64String != null && base64String.isNotEmpty) {
                                  try {
                                    imageProvider = MemoryImage(base64Decode(base64String));
                                  } catch (e) {
                                    print("Erro ao decodificar imagem: $e");
                                  }
                                }
                              }

                              // Borda translúcida em volta do avatar
                              return Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.2),
                                ),
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.white, // Fundo branco para destaque
                                  backgroundImage: imageProvider,
                                  child: _isUploading
                                      ? const CircularProgressIndicator()
                                      : (imageProvider == null
                                      ? Icon(Icons.person, size: 80, color: _mainPurple)
                                      : null),
                                ),
                              );
                            },
                          ),
                        ),
                        // Botão de Câmera
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _isUploading ? null : _pickAndSaveImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _mainPurple,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- CORPO (CONTAINER ARREDONDADO) ---
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
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 40),
                children: [
                  // Infos
                  _buildInfoTile(
                      context: context,
                      icon: Icons.person_outlined,
                      label: 'Nome',
                      value: userName,
                      textColor: textColor, isDark: isDark
                  ),
                  _buildInfoTile(
                      context: context,
                      icon: Icons.email_outlined,
                      label: 'E-mail',
                      value: userEmail,
                      textColor: textColor, isDark: isDark
                  ),

                  Consumer<ScoreProvider>(
                    builder: (context, provider, child) {
                      return _buildInfoTile(
                          context: context,
                          icon: Icons.star_outlined,
                          label: 'Pontuação Total',
                          value: provider.score.toString(),
                          textColor: textColor, isDark: isDark
                      );
                    },
                  ),

                  _buildInfoTile(
                      context: context,
                      icon: levelIcon,
                      label: 'Nível Atual',
                      value: userLevel,
                      textColor: textColor, isDark: isDark
                  ),

                  const SizedBox(height: 24),

                  // Cursos em Andamento
                  StreamBuilder<List<Trail>>(
                    stream: _trailService.getTrailsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return Text('Erro ao carregar cursos.', style: TextStyle(color: textColor));
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator(color: _mainPurple));
                      }

                      final allTrails = snapshot.data ?? [];
                      final inProgressTrails = allTrails.where((trail) {
                        if (trail.lessonIds.isEmpty) return false;
                        int completedCount = trail.lessonIds.where((id) => completedIds.contains(id)).length;
                        double progress = completedCount / trail.lessonIds.length;
                        return progress > 0.0 && progress < 1.0;
                      }).toList();

                      return _buildInProgressSection(context, inProgressTrails, completedIds, textColor, isDark);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInProgressSection(
      BuildContext context, List<Trail> inProgressTrails, Set<String> completedIds, Color textColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cursos em Andamento',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 16),
        if (inProgressTrails.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Nenhum curso em andamento.',
                style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 16),
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
              double progress = 0.0;
              if (trail.lessonIds.isNotEmpty) {
                int completedCount = trail.lessonIds.where((id) => completedIds.contains(id)).length;
                progress = completedCount / trail.lessonIds.length;
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildProgressCard(context: context, trail: trail, progress: progress, isDark: isDark, textColor: textColor),
              );
            },
          ),
      ],
    );
  }

  Widget _buildProgressCard({
    required BuildContext context,
    required Trail trail,
    required double progress,
    required bool isDark,
    required Color textColor,
  }) {
    String percentageLabel = '${(progress * 100).toInt()}%';
    // Ajuste de cores do card para o modo dark
    final cardBg = isDark ? const Color(0xFF2A2A2D) : Colors.white;
    final borderColor = isDark ? Colors.white10 : Colors.transparent;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => TrailScreen(trail: trail))),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
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
                  decoration: BoxDecoration(color: _mainPurple.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                  child: Icon(trail.icon, color: _mainPurple, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(trail.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 4),
                      Text('${trail.lessonIds.length} Lições • ${trail.level}', style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 12)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: textColor.withOpacity(0.5)),
              ],
            ),
            const SizedBox(height: 16),
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(_mainPurple),
                    minHeight: 16,
                  ),
                ),
                Positioned.fill(child: Center(child: Text(percentageLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)))),
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
    required Color textColor,
    required bool isDark,
  }) {
    final cardBg = isDark ? const Color(0xFF2A2A2D) : Colors.white;

    return Card(
      color: cardBg,
      elevation: isDark ? 0 : 2,
      shadowColor: AppColors.shadowColor.withOpacity(0.1),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDark ? const BorderSide(color: Colors.white10) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon, color: _mainPurple, size: 28),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(value, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}