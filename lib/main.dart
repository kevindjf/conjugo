import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/games_menu_page.dart';

void main() {
  runApp(const ProviderScope(child: ConjugoApp()));
}

class ConjugoApp extends StatelessWidget {
  const ConjugoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conjugo (enfant)',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: const Color(0xFFFFFBF2),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const GamesMenuPage(),
    );
  }
}
