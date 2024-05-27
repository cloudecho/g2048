import 'package:flutter/material.dart';
import 'package:g2048/src/types.dart';
import 'dart:math' as math;

const _rank = 4;

class GameState extends ChangeNotifier {
  GameState()
      : _model = List.generate(
          _rank,
          (_) => List.filled(_rank, 0, growable: false),
          growable: false,
        ) {
    _init();
  }

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

  void swipeLeft() {
    for (var i = 0; i < size; i++) {
      _swipeLeft(i);
    }
    _nextNum();
  }

  void _swipeLeft(final int i) {
    var k = 0; // number of zeros
    for (; k < size && 0 == _model[i][k]; k++) {}
    if (k == size - 1) {
      // all zeros
      return;
    }
    // shift k
    for (var j = 0; j < size - k; j++) {
      _model[i][j] = _model[i][j + k];
    }
  }

  void swipeRight() {
    _nextNum();
  }

  void swipeUp() {
    _nextNum();
  }

  void swipeDown() {
    _nextNum();
  }

  static final _rand = math.Random();

  bool _nextNum() {
    List<Point> points = [];
    for (var i = 0; i < size; i++) {
      for (var j = 0; j < size; j++) {
        if (0 == _model[i][j]) points.add((x: i, y: j));
      }
    }
    if (points.isEmpty) return false;

    var p = points[_rand.nextInt(points.length)];
    _model[p.x][p.y] = 2; // TODO 4
    notifyListeners();
    return true;
  }
}
