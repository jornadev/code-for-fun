import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Adicionado para buscar o usuário
import 'package:code_for_fun/model/trail_model.dart';
import 'package:code_for_fun/service/trail_service.dart';
import 'package:code_for_fun/screens/trail_screen.dart';
import 'package:code_for_fun/screens/settings_screen.dart';

// 1. A classe foi convertida para StatefulWidget para gerenciar o estado do nome.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 2. Variável de estado para armazenar o nome do usuário.
  String _userName = '...'; // Inicia com um placeholder

  @override
  void initState() {
    super.initState();
    // 3. Função chamada para carregar o nome do usuário quando a tela é iniciada.
    _loadUserName();
  }

  void _loadUserName() {
    final user = FirebaseAuth.instance.currentUser;
    // Verifica se o usuário está logado e tem um nome de exibição definido.
    if (user != null && user.displayName != null && user.displayName!.isNotEmpty) {
      setState(() {
        // Atualiza a variável de estado com o nome do usuário.
        // toUpperCase() é usado para manter o estilo "BEM VINDO, NOME".
        _userName = user.displayName!.toUpperCase();
      });
    } else {
      // Se não houver nome, usa um valor padrão.
      setState(() {
        _userName = 'JOGADOR';
      });
    }
  }

  // A partir daqui, é o seu código original.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 4. Passa a variável _userName para o método que constrói o cabeçalho.
            _buildHeader(context, _userName),
            _buildContinueSection(context),
            const SizedBox(height: 24),
            _buildRecommendedSection(context),
            const SizedBox(height: 24),
            _buildYourTrailsSection(context),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey[400],
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 3) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          }
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Ranking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }

  // 5. O método _buildHeader agora aceita o nome como um parâmetro.
  Widget _buildHeader(BuildContext context, String userName) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // 6. AQUI! O nome estático foi trocado pela variável dinâmica.
                  'BEM VINDO, $userName',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pronto para o próximo desafio?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                const Text(
                  '250',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // O restante do seu código original, sem nenhuma alteração.
  Widget _buildContinueSection(BuildContext context) {
    // No seu trail_service.dart original, você não tinha o método getUserTrails.
    // Estou usando getRecommendedTrails() para evitar erros, conforme seu código anterior.
    final userTrails = TrailService.getRecommendedTrails();
    final firstTrail = userTrails.isNotEmpty ? userTrails.first : null;

    if (firstTrail == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Retome de onde parou',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildProgressCard(
            context,
            trail: firstTrail,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trilhas Recomendadas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: TrailService.getRecommendedTrails().map((trail) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _buildTrailCard(context, trail: trail),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYourTrailsSection(BuildContext context) {
    // Novamente, usando getRecommendedTrails para manter a consistência com o código original
    final userTrails = TrailService.getRecommendedTrails();
    if (userTrails.length <= 1) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Suas trilhas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: userTrails.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final trail = userTrails[index];
              return _buildProgressCard(context, trail: trail);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, {required Trail trail}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TrailScreen(trail: trail)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: trail.iconColor.withOpacity(0.1),
              child: Icon(trail.icon, color: trail.iconColor, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trail.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildProgressBar(trail.progress, '${(trail.progress * 100).toStringAsFixed(0)}%'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailCard(BuildContext context, {required Trail trail}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TrailScreen(trail: trail)),
        );
      },
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: trail.iconColor.withOpacity(0.1),
              child: Icon(trail.icon, color: trail.iconColor),
            ),
            const SizedBox(height: 12),
            Text(
              trail.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              trail.level,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  '4.5',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(double progress, String percentageLabel) {
    return Stack(
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
          borderRadius: BorderRadius.circular(10),
          minHeight: 16,
        ),
        Positioned.fill(
          child: Center(
            child: Text(
              percentageLabel,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}