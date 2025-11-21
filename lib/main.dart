import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:provider/provider.dart';
import 'package:code_for_fun/providers/theme_provider.dart';
import 'package:code_for_fun/providers/score_provider.dart';
import 'package:code_for_fun/screens/splash_screen.dart';
import 'package:code_for_fun/screens/main_navigation_screen.dart'; // Adicionado para uso futuro

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Cor principal do aplicativo
  final Color _mainPurple = const Color(0xFF673AB7);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ScoreProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          final isDark = themeProvider.isDarkTheme;

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Code4Fun',

            // --- TEMA CLARO ---
            theme: ThemeData(
                brightness: Brightness.light,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: _mainPurple,
                  primary: _mainPurple,
                  // Garantimos que a cor secundária seja o roxo principal
                  secondary: _mainPurple,
                ),
                scaffoldBackgroundColor: const Color(0xFFF0F0F5),
                cardColor: Colors.white,
                textTheme: const TextTheme(
                  bodyLarge: TextStyle(color: Colors.black87),
                ),
                appBarTheme: const AppBarTheme(
                  iconTheme: IconThemeData(color: Colors.black),
                )
            ),

            // --- TEMA ESCURO ---
            darkTheme: ThemeData(
                brightness: Brightness.dark,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: _mainPurple,
                  primary: _mainPurple,
                  secondary: _mainPurple,
                  brightness: Brightness.dark,
                ),
                scaffoldBackgroundColor: const Color(0xFF1B1B1E),
                cardColor: const Color(0xFF2A2A2D),
                textTheme: const TextTheme(
                  bodyLarge: TextStyle(color: Colors.white),
                ),
                appBarTheme: const AppBarTheme(
                  iconTheme: IconThemeData(color: Colors.white),
                )
            ),

            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            // A tela inicial deve ser o SplashScreen para resolver o Auth
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}