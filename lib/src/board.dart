import 'package:flutter/material.dart';
import 'package:g2048/src/game_state.dart';
import 'package:g2048/src/swipeable.dart';
import 'package:provider/provider.dart';

class Board extends StatelessWidget {
  const Board({super.key});

  @override
  Widget build(BuildContext context) {
    var state = context.watch<GameState>();
    var theme = Theme.of(context);
    return Swipeable(
      onSwipeLeft: state.swipeLeft,
      onSwipeRight: state.swipeRight,
      onSwipeUp: state.swipeUp,
      onSwipeDown: state.swipeDown,
      child: _board(state, theme),
    );
  }

  Column _board(GameState state, ThemeData theme) {
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
