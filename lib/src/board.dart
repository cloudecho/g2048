import 'package:flutter/material.dart';
import 'package:g2048/src/constants.dart';
import 'package:g2048/src/game_state.dart';
import 'package:g2048/src/style/slide_widget.dart';
import 'package:g2048/src/style/twinkle_widget.dart';
import 'package:g2048/src/style/swipeable.dart';
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
      size: state.size * kTileSize,
      child: Container(
          width: state.size * (kTileSize + 3 * kMargin),
          height: state.size * (kTileSize + 3 * kMargin),
          decoration: const BoxDecoration(
            color: kMainColor,
            borderRadius: BorderRadius.all(Radius.circular(kMargin)),
          ),
          child: _board(state, theme)),
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
      width: kTileSize,
      height: kTileSize,
      margin: const EdgeInsets.all(kMargin),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: const BorderRadius.all(Radius.circular(kMargin)),
      ),
      child: Align(
        alignment: Alignment.center,
        child: Text(
          num > 0 ? '$num' : '',
          style: theme.textTheme.displayMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: _fontColor,
          ),
        ),
      ),
    );
    return SlideWidget(
      key: Key('${key?.toString()}-${DateTime.now().microsecond}'),
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

  Color get _bgColor => num > 0 ? kMainColor.shade200 : kMainColor.shade400;

  Color get _fontColor => Colors.black54;
}
