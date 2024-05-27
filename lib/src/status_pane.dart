import 'package:flutter/material.dart';
import 'package:g2048/src/constants.dart';
import 'package:g2048/src/game_state.dart';
import 'package:provider/provider.dart';

class StatusPane extends StatelessWidget {
  const StatusPane({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var state = context.watch<GameState>();
    var theme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text('2048', style: _textStyle(theme.displayLarge!)),
        Column(
          children: [
            Text('SCORE', style: _textStyle(theme.bodyMedium!)),
            Text('${state.score}', style: _textStyle(theme.displayMedium!)),
          ],
        ),
      ],
    );
  }

  TextStyle _textStyle(TextStyle style) {
    return style.copyWith(
      color: kMainColor,
      fontWeight: FontWeight.bold,
    );
  }
}
