import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:code_for_fun/screens/login_screen.dart';
import 'package:code_for_fun/constants/app_colors.dart';
import 'package:code_for_fun/providers/score_provider.dart';
import 'package:code_for_fun/providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Color _mainPurple = const Color(0xFF673AB7);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetColor = isDark ? const Color(0xFF1B1B1E) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textDark;

    return Scaffold(
      backgroundColor: _mainPurple,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 30),
              child: Center(
                child: Text(
                  'Ajustes',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),

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
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
                children: [
                  _buildSectionTitle('Aparência', textColor),
                  _buildSettingsTile(
                    context,
                    icon: Icons.brightness_6_outlined,
                    title: themeProvider.isDarkTheme ? 'Modo Claro' : 'Modo Escuro',
                    onTap: () => themeProvider.toggleTheme(),
                    isDark: isDark,
                    textColor: textColor,
                  ),

                  const SizedBox(height: 10),

                  _buildSectionTitle('Conta e Segurança', textColor),
                  _buildSettingsTile(
                    context,
                    icon: Icons.person_outline,
                    title: 'Editar Nome',
                    onTap: () => _showEditNameDialog(context),
                    isDark: isDark,
                    textColor: textColor,
                  ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.lock_outline,
                    title: 'Mudar Senha',
                    onTap: () => _sendPasswordReset(context),
                    isDark: isDark,
                    textColor: textColor,
                  ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.logout,
                    title: 'Sair',
                    onTap: () => _logout(context),
                    isDark: isDark,
                    textColor: textColor,
                  ),


                  const SizedBox(height: 10),

                  _buildSectionTitle('Informações', textColor),
                  _buildSettingsTile(
                    context,
                    icon: Icons.info_outline,
                    title: 'Sobre o App',
                    onTap: () => _showAboutDialog(context),
                    isDark: isDark,
                    textColor: textColor,
                  ),

                  const SizedBox(height: 30),

                  _buildSectionTitle('Ações Destrutivas', textColor),
                  _buildDestructiveTile(
                    context,
                    icon: Icons.restart_alt,
                    title: 'Resetar Progresso',
                    onTap: () => _showResetConfirmationDialog(context),
                    isDark: isDark,
                  ),
                  _buildDestructiveTile(
                    context,
                    icon: Icons.delete_forever,
                    title: 'Excluir Conta',
                    onTap: () => _showDeleteAccountDialog(context),
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0, top: 10),
      child: Text(
        title,
        style: TextStyle(
          color: textColor.withOpacity(0.6),
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
        required bool isDark,
        required Color textColor,
      }) {
    final cardBg = isDark ? const Color(0xFF2A2A2D) : Colors.white;
    final borderColor = isDark ? Colors.white10 : Colors.grey.shade200;

    return Card(
      elevation: isDark ? 0 : 1,
      color: cardBg,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor),
      ),
      child: ListTile(
        leading: Icon(icon, color: _mainPurple),
        title: Text(
          title,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: textColor.withOpacity(0.4),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDestructiveTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
        required bool isDark,
      }) {
    final cardBg = isDark
        ? AppColors.red.withOpacity(0.15)
        : AppColors.red.withOpacity(0.05);

    return Card(
      elevation: 0,
      color: cardBg,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.red.withOpacity(0.3)),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.red),
        title: Text(
          title,
          style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.bold),
        ),
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
              style: ElevatedButton.styleFrom(backgroundColor: _mainPurple),
              onPressed: () async {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  try {
                    await user.updateDisplayName(newName);

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .update({'displayName': newName});

                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nome atualizado com sucesso!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erro ao atualizar o nome: $e'),
                          backgroundColor: AppColors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('Salvar', style: TextStyle(color: Colors.white)),
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
          content: const Text(
            'Este aplicativo foi desenvolvido para tornar o aprendizado de programação divertido e interativo.\n\nVersão 1.0.0',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(foregroundColor: _mainPurple),
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
          content: const Text(
            'Tem certeza?\nTodo o seu progresso (pontos e lições completas) será permanentemente apagado e zerado.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  await Provider.of<ScoreProvider>(context, listen: false)
                      .resetAccountProgress();

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Progresso resetado com sucesso!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao resetar: ${e.toString()}'),
                        backgroundColor: AppColors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text(
                'Resetar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false,
      );
    }
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir Conta?'),
          content: const Text(
            'Esta ação é irreversível. Seus dados serão apagados permanentemente e você será deslogado.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _deleteAccount(context);
              },
              child: const Text(
                'Excluir Definitivamente',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
      await user.delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conta excluída com sucesso.')),
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (Route<dynamic> route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por segurança, faça login novamente antes de excluir a conta.'),
              backgroundColor: AppColors.red,
            ),
          );
          _logout(context);
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir: ${e.message}')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }
}