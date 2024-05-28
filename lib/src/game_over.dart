import 'package:flutter/material.dart';
import 'package:g2048/src/constants.dart';
import 'package:g2048/src/game_state.dart';
import 'package:provider/provider.dart';

class GameOver extends StatelessWidget {
  const GameOver({super.key});

  @override
  Widget build(BuildContext context) {
    var state = context.watch<GameState>();
    var theme = Theme.of(context).textTheme;
    return Visibility(
      visible: state.done,
      child: SizedBox(
        width: state.boardSize,
        height: state.boardSize,
        child: Container(
          color: Colors.black38,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'GAME OVER',
                style: theme.displaySmall!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.restart_alt_outlined),
                iconSize: kTileSize,
                onPressed: () => state.restart(),
                color: Colors.white70,
              )
            ],
          ),
        ),
      ),
    );
  }
}
