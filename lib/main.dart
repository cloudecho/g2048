import 'package:flutter/material.dart';
import 'package:g2048/src/board.dart';
import 'package:g2048/src/game_state.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ChangeNotifierProvider(
        create: (context) => GameState(),
        child: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var state = context.watch<GameState>();
    return Scaffold(
      appBar: AppBar(title: const Text('2048')),
      body: Column(
        children: [
          Text('${state.score}'),
          const Board(),
        ],
      ),
    );
  }
}
