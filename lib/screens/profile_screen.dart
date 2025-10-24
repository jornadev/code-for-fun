import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:code_for_fun/providers/score_provider.dart';
import 'package:code_for_fun/constants/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String userName = user?.displayName ?? 'Usuário Anônimo';
    final String userEmail = user?.email ?? 'email@nao-encontrado.com';

    return Container(
      color: AppColors.lightGray,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 32),
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.primaryPurple.withOpacity(0.1),
                child: const Icon(
                  Icons.person,
                  size: 80,
                  color: AppColors.primaryPurple,
                ),
              ),
            ),
            const SizedBox(height: 40),

            _buildInfoTile(
              icon: Icons.person_outline,
              label: 'Nome',
              value: userName,
            ),

            _buildInfoTile(
              icon: Icons.email_outlined,
              label: 'Email',
              value: userEmail,
            ),

            Consumer<ScoreProvider>(
              builder: (context, provider, child) {
                return _buildInfoTile(
                  icon: Icons.star_outline,
                  label: 'Pontuação Total',
                  value: provider.isLoading ? 'Carregando...' : provider.score.toString(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value
  }) {
    return Card(
      elevation: 2,
      shadowColor: AppColors.shadowColor.withOpacity(0.1),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryPurple, size: 28),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: AppColors.textLight, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}