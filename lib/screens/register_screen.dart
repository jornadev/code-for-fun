import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:code_for_fun/constants/app_colors.dart'; // Certifique-se de que AppColors está definido
import 'package:code_for_fun/screens/login_screen.dart';
import 'package:code_for_fun/screens/main_navigation_screen.dart';
import 'package:code_for_fun/service/user_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _userService = UserService();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.red, // Usa a cor de erro do seu AppColors
      ),
    );
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        final String name = _nameController.text.trim();

        await user.updateDisplayName(name);

        await _userService.createUserDocument(user, name);

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
                (Route<dynamic> route) => false,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Erro ao cadastrar.';
      if (e.code == 'email-already-in-use') {
        message = 'Este e-mail já está cadastrado.';
      } else if (e.code == 'weak-password') {
        message = 'A senha é muito fraca.';
      } else if (e.code == 'invalid-email') {
        message = 'E-mail inválido.';
      }
      _showErrorSnackBar(message);
    } catch (e) {
      _showErrorSnackBar('Erro: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 💡 CORES FIXAS PARA MODO CLARO (IGNORA O TEMA GLOBAL)
    const Color lightBackgroundColor = Colors.white;
    // Assumindo AppColors.textDark é a cor escura que você usa para texto em fundo claro
    const Color lightTextColor = AppColors.textDark;

    return Scaffold(
      // 1. Fundo do Scaffold (Sempre Branco)
      backgroundColor: lightBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        // 2. Cor dos Ícones no AppBar (Sempre Escuro)
        iconTheme: const IconThemeData(color: lightTextColor),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/images/duck.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Crie sua conta',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        // 3. Cor do Título (Sempre Escuro)
                        color: lightTextColor
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildTextField(
                    controller: _nameController,
                    label: 'Nome',
                    icon: Icons.person,
                    validator: (value) => (value?.isEmpty ?? true) ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _emailController,
                    label: 'E-mail',
                    icon: Icons.email,
                    inputType: TextInputType.emailAddress,
                    validator: (value) => (value?.isEmpty ?? true) ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _passwordController,
                    label: 'Senha',
                    icon: Icons.lock,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Campo obrigatório';
                      if (value.length < 6) return 'Senha deve ter 6+ caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirmar Senha',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    validator: (value) {
                      if (value != _passwordController.text) return 'As senhas não conferem';
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        'CADASTRAR',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 14),
                          children: [
                            TextSpan(
                              text: 'Já tem uma conta? ',
                              // 4. Cor do Texto de Rodapé (Sempre Escuro, semi-transparente)
                              style: TextStyle(color: lightTextColor.withOpacity(0.7)),
                            ),
                            const TextSpan(
                              text: 'Faça login',
                              style: TextStyle(
                                color: AppColors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? inputType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: inputType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}