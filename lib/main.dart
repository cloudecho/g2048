import 'package:flutter/material.dart';
import 'package:g2048/src/board.dart';
import 'package:g2048/src/constants.dart';
import 'package:g2048/src/game_over.dart';
import 'package:g2048/src/game_state.dart';
import 'package:g2048/src/status_pane.dart';
import 'package:g2048/src/version.dart';
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
      title: '2048',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: kMainColor),
          useMaterial3: true,
          bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: Colors.transparent,
          )),
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
      bottomSheet: Padding(
        padding: EdgeInsets.all(kTileSize / 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('ver: $kVersion'),
          ],
        ),
      ),
      body: Center(
        child: SizedBox(
          width: kMaxWidth,
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
      ),
    );
  }
}
