import 'package:flutter/material.dart';

typedef Model = List<List<int>>;

class GameState extends ChangeNotifier {
  GameState()
      : _model = List.generate(
          _rank,
          (_) => List.filled(_rank, 0, growable: false),
          growable: false,
        ) {
    _init();
  }

  static const _rank = 4;

  int get size => _rank;

  final Model _model;
  int score = 0;

  void _init() {
    _model[size - 1][0] = 2;
    _model[size - 2][0] = 2;
  }

  void _reset() {
    for (var i = 0; i < size; i++) {
      for (var j = 0; j < size; j++) {
        _model[i][j] = 0;
      }
    }
    score = 0;
  }

  int num(int i, int j) => _model[i][j];
  String text(int i, int j) => 0 == num(i, j) ? '' : '${num(i, j)}';

  void moveLeft() {}
  void moveRight() {}
  void moveUp() {}
  void moveDown() {}
}
