import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:g2048/src/board.dart';
import 'package:g2048/src/constants.dart';
import 'package:g2048/src/game_over.dart';
import 'package:g2048/src/game_state.dart';
import 'package:g2048/src/status_pane.dart';
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
        colorScheme: ColorScheme.fromSeed(seedColor: kMainColor),
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
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StatusPane(),
            SizedBox(height: kTileSize / 2),
            Stack(children: [
              Board(),
              GameOver(),
            ]),
          ],
        ),
      ),
    );
  }
}
