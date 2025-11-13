import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:code_for_fun/screens/login_screen.dart';
import 'package:code_for_fun/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:code_for_fun/providers/score_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        const SizedBox(height: 60),
        const Padding(
          padding: EdgeInsets.only(bottom: 20.0),
          child: Text(
            'Ajustes',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ),
        _buildSectionTitle('Conta'),
        _buildSettingsTile(
          context,
          icon: Icons.person_outline,
          title: 'Editar Nome',
          onTap: () => _showEditNameDialog(context),
        ),
        _buildSettingsTile(
          context,
          icon: Icons.lock_outline,
          title: 'Mudar Senha',
          onTap: () => _sendPasswordReset(context),
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('Mais Informações'),
        _buildSettingsTile(
          context,
          icon: Icons.info_outline,
          title: 'Sobre o App',
          onTap: () => _showAboutDialog(context),
        ),
        const SizedBox(height: 32),
        _buildDestructiveTile(
          context,
          icon: Icons.restart_alt,
          title: 'Resetar Progresso',
          onTap: () => _showResetConfirmationDialog(context),
        ),
        _buildDestructiveTile(
          context,
          icon: Icons.logout,
          title: 'Sair',
          onTap: () => _logout(context),
        ),
        _buildDestructiveTile(
          context,
          icon: Icons.delete_forever,
          title: 'Excluir Conta',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Função de excluir conta ainda não implementada.'),
                backgroundColor: AppColors.textLight,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textLight,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    return Card(
      elevation: 1,
      shadowColor: AppColors.shadowColor.withOpacity(0.1),
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.orange),
        title: Text(title, style: const TextStyle(color: AppColors.textDark)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textLight),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDestructiveTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    return Card(
      elevation: 0,
      color: AppColors.red.withOpacity(0.05),
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.red.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.red),
        title: Text(title, style: const TextStyle(color: AppColors.red)),
        onTap: onTap,
      ),
    );
  }

  void _showEditNameDialog(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final nameController = TextEditingController(text: user.displayName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Nome'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Novo nome'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  try {
                    await user.updateDisplayName(newName);

                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nome atualizado! (Pode ser necessário reiniciar o app para ver a mudança)'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao atualizar o nome: $e'),
                        backgroundColor: AppColors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _sendPasswordReset(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro: Usuário não encontrado ou sem e-mail.'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('E-mail de redefinição de senha enviado!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar e-mail: $e'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sobre o Code for Fun'),
          content: const Text('Este aplicativo foi desenvolvido para tornar o aprendizado de programação divertido e interativo.\n\nVersão 1.0.0'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  void _showResetConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Resetar Progresso?'),
          content: const Text('Tem certeza?\nTodo o seu progresso (pontos e lições completas) será permanentemente apagado e zerado.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  await Provider.of<ScoreProvider>(context, listen: false)
                      .resetAccountProgress();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Progresso resetado com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao resetar: ${e.toString()}'),
                      backgroundColor: AppColors.red,
                    ),
                  );
                }
              },
              child: const Text('Resetar', style: TextStyle(color: AppColors.white)),
            ),
          ],
        );
      },
    );
  }

  void _logout(BuildContext context) async {
    Provider.of<ScoreProvider>(context, listen: false).resetScore();
    await FirebaseAuth.instance.signOut();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }
}