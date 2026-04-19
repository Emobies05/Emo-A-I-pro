import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/butterfly_controller.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ButterflyState(),
      child: const EmoAIProApp(),
    ),
  );
}

class EmoAIProApp extends StatelessWidget {
  const EmoAIProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emo AI Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}
