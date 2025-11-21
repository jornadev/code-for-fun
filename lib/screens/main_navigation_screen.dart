import 'package:flutter/material.dart';
import 'package:code_for_fun/screens/home_screen.dart';
import 'package:code_for_fun/screens/ranking_screen.dart';
import 'package:code_for_fun/screens/profile_screen.dart';
import 'package:code_for_fun/screens/settings_screen.dart';
import 'package:code_for_fun/screens/achievements_screen.dart'; // IMPORT NECESSÁRIO

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // Cor Roxo Principal para destaque
  final Color _mainPurple = const Color(0xFF673AB7);

  // Lista de telas com a nova ordem: Home, Ranking, Conquistas, Perfil, Ajustes
  static final List<Widget> _screens = <Widget>[
    const HomeScreen(),
    const RankingScreen(),
    const AchievementsScreen(), // NOVO: Conquistas
    ProfileScreen(),
    const SettingsScreen(),
  ];

  static final List<PreferredSizeWidget?> _appBars = <PreferredSizeWidget?>[
    null,
    null,
    null,
    null,
    null, // Mantenho 5 nulls, um para cada tela
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color selectedColor = _mainPurple; // Roxo Principal
    final Color unselectedColor =
        theme.iconTheme.color?.withOpacity(0.5) ?? Colors.grey;
    final Color navBackground =
        theme.bottomAppBarTheme.color ??
            (isDark ? const Color(0xFF1B1B1E) : Colors.white);

    return Scaffold(
      // Usamos a lista de AppBars com 5 itens
      appBar: _appBars[_selectedIndex],
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: navBackground,
        selectedItemColor: selectedColor,
        unselectedItemColor: unselectedColor,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Ranking',
          ),
          // NOVO ITEM: CONQUISTAS
          BottomNavigationBarItem(
            icon: Icon(Icons.workspace_premium_rounded),
            label: 'Conquistas',
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
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}