import 'package:flutter/material.dart';
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
          create: (context) => GameState(), child: const HomeScreen()),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('2048')),
      body: const Board(),
    );
  }
}

class Board extends StatelessWidget {
  const Board({super.key});

  @override
  Widget build(BuildContext context) {
    var state = context.watch<GameState>();
    var theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < state.size; i++)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var j = 0; j < state.size; j++)
                Container(
                  width: 89,
                  height: 89,
                  color: state.num(i, j) > 0
                      ? Colors.brown.shade200
                      : Colors.brown,
                  margin: const EdgeInsets.all(4),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      state.text(i, j),
                      style: theme.textTheme.headlineLarge!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                )
            ],
          )
      ],
    );
  }
}
