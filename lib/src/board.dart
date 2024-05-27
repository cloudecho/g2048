import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:g2048/src/constants.dart';
import 'package:g2048/src/game_state.dart';
import 'package:g2048/src/style/slide_widget.dart';
import 'package:g2048/src/style/twinkle_widget.dart';
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
      size: state.size * 90 * 0.9,
      child: _board(state, theme),
    );
  }

  Widget _board(GameState state, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < state.size; i++)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var j = 0; j < state.size; j++)
                Tile(
                  key: Key('tile-$i-$j'),
                  num: state.num(i, j),
                  isNew: state.isNewPosition(i, j),
                  offset: state.slideOffset(i, j),
                  theme: theme,
                )
            ],
          )
      ],
    );
  }
}

class Tile extends StatelessWidget {
  const Tile({
    super.key,
    required this.num,
    required this.isNew,
    required this.offset,
    required this.theme,
  });

  final int num;
  final bool isNew;
  final Offset offset;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    var w = Container(
      width: 89,
      height: 89,
      color: num > 0 ? Colors.brown.shade200 : Colors.brown,
      margin: const EdgeInsets.all(4),
      child: Align(
        alignment: Alignment.center,
        child: Text(
          num > 0 ? '$num' : '',
          style: theme.textTheme.displayMedium!
              .copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
    return SlideWidget(
      offset: offset,
      duration: const Duration(milliseconds: kSlideMilliseconds),
      child: TwinkleWidget(
        begin: isNew ? 0.2 : 1.0,
        end: 1.0,
        repeat: false,
        speed: const Duration(milliseconds: kTwinkleMilliseconds),
        child: w,
      ),
    );
  }
}
