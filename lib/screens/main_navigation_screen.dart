import 'package:flutter/material.dart';
import 'package:code_for_fun/screens/home_screen.dart';
import 'package:code_for_fun/screens/profile_screen.dart';
import 'package:code_for_fun/screens/settings_screen.dart';
import 'package:code_for_fun/screens/ranking_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = <Widget>[
    const HomeScreen(),
    const RankingScreen(),
    const ProfileScreen(),
    const SettingsScreen(),
  ];

  static final List<PreferredSizeWidget?> _appBars = <PreferredSizeWidget?>[
    null,
    null,
    null,
    null,
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

    final Color selectedColor = theme.colorScheme.secondary;
    final Color unselectedColor =
        theme.iconTheme.color?.withOpacity(0.5) ?? Colors.grey;
    final Color navBackground =
        theme.bottomAppBarTheme.color ??
            (isDark ? const Color(0xFF121212) : Colors.white);

    return Scaffold(
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
