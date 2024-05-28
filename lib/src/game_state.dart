import 'package:flutter/material.dart';
import 'package:g2048/src/constants.dart';
import 'package:g2048/src/types.dart';
import 'dart:math' as math;

const _rank = 4;

class GameState extends ChangeNotifier {
  GameState()
      : _model = List.generate(
          _rank,
          (_) => List.filled(_rank, 0, growable: false),
          growable: false,
        ),
        _offsets = List.generate(
          _rank,
          (_) => List.filled(_rank, Offset.zero, growable: false),
          growable: false,
        ) {
    _init();
  }

  int get size => _rank;
  double get boardSize => size * (kTileSize + 3 * kMargin);

  final Model _model;
  final List<List<Offset>> _offsets;
  int score = 0;
  bool done = false;

  void _init() {
    _model[size - 1][0] = 2;
    _model[size - 2][0] = 2;
  }

  void _reset() {
    for (var i = 0; i < size; i++) {
      for (var j = 0; j < size; j++) {
        _model[i][j] = 0;
        _offsets[i][j] = Offset.zero;
      }
    }
    score = 0;
    done = false;
  }

  void restart() {
    _reset();
    _init();
    notifyListeners();
  }

  int num(int i, int j) => _model[i][j];
  Offset slideOffset(int i, int j) => _offsets[i][j];

  void swipeLeft() {
    _swipe(_swipeLeft);
  }

  void swipeRight() {
    _swipe(_swipeRight);
  }

  void swipeUp() {
    _swipe(_swipeUp);
  }

  void swipeDown() {
    _swipe(_swipeDown);
  }

  void _swipe(void Function(int) swipeAction) async {
    _resetNewPosition();
    for (var i = 0; i < size; i++) {
      swipeAction(i);
    }
    notifyListeners();

    await _sleep(kSlideMilliseconds);
    for (var k = 0; k < size; k++) {
      final vertical = swipeAction == _swipeUp || swipeAction == _swipeDown;
      var nums = _nums(k, column: vertical);
      _mergeNumbers(
        nums,
        reserve: swipeAction == _swipeRight || swipeAction == _swipeDown,
      );
      swipeAction(k);
    }
    _nextNum();
    _checkDone();
    notifyListeners();
  }

  void _checkDone() {
    for (var k = 0; k < size; k++) {
      if (!_isDone(_nums(k)) || !_isDone(_numsAtColumn(k))) {
        return;
      }
    }
    done = true;
  }

  bool _isDone(Nums nums) {
    for (var k = 0; k < nums.length; k++) {
      if (0 == nums[k] || (k > 0 && nums[k - 1] == nums[k])) {
        return false;
      }
    }
    return true;
  }

  void _resetNewPosition() {
    _newPostion = null;
  }

  Future<void> _sleep(int milliseconds) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }

  void _swipeLeft(final int i) {
    var moves = _removeZeros(_nums(i));
    for (var k = 0; k < size; k++) {
      _offsets[i][k] = Offset(moves[k].toDouble(), 0);
    }
  }

  void _swipeRight(final int i) {
    var moves = _removeZeros(_nums(i), reverse: true);
    for (var k = 0; k < size; k++) {
      _offsets[i][k] = Offset(-moves[k].toDouble(), 0);
    }
  }

  void _swipeUp(final int j) {
    var nums = _numsAtColumn(j);
    var moves = _removeZeros(nums);
    for (var k = 0; k < size; k++) {
      _offsets[k][j] = Offset(0, moves[k].toDouble());
    }
  }

  void _swipeDown(final int j) {
    var nums = _nums(j, column: true);
    var moves = _removeZeros(nums, reverse: true);
    for (var k = 0; k < size; k++) {
      _offsets[k][j] = Offset(0, -moves[k].toDouble());
    }
  }

  Nums _numsAtColumn(int j) => _nums(j, column: true);

  void _mergeNumbers(Nums nums, {bool reserve = false}) {
    if (reserve) {
      for (var k = nums.length - 1; k > 0; k--) {
        if (nums[k] == nums[k - 1]) {
          nums[k] *= 2;
          nums[k - 1] = 0;
          score += nums[k];
        }
      }
    } else {
      for (var k = 0; k < nums.length - 1; k++) {
        if (nums[k] == nums[k + 1]) {
          nums[k] *= 2;
          nums[k + 1] = 0;
          score += nums[k];
        }
      }
    }
  }

  List<int> _removeZeros(Nums nums, {bool reverse = false}) {
    var moves = List.filled(nums.length, 0, growable: false);
    if (reverse) {
      for (var k = nums.length - 2; k >= 0; k--) {
        if (nums[k] == 0) continue;
        var i = k + 1;
        for (; i < nums.length && nums[i] == 0; i++) {}
        var count = i - (k + 1);
        if (count > 0) {
          nums[i - 1] = nums[k];
          nums[k] = 0;
          moves[i - 1] = count;
        }
      }
    } else {
      for (var k = 1; k < nums.length; k++) {
        if (nums[k] == 0) continue;
        var i = k - 1;
        for (; i >= 0 && nums[i] == 0; i--) {}
        var count = (k - 1) - i;
        if (count > 0) {
          nums[i + 1] = nums[k];
          nums[k] = 0;
          moves[i + 1] = count;
        }
      }
    }
    // debugPrint('moves: $moves');
    return moves;
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
    _model[p.x][p.y] = _rand.nextDouble() < 0.1 ? 4 : 2;
    _newPostion = p;
    return true;
  }

  Point? _newPostion;

  bool isNewPosition(int x, int y) {
    return _newPostion == (x: x, y: y);
  }

  Nums _nums(int which, {bool column = false}) =>
      Nums(_model, which, column: column);
}

/// A row or a column of numbers
class Nums {
  Nums(this.model, this.which, {this.column = false});
  final Model model;

  /// Which row or column
  final int which;
  final bool column;

  int get length => column ? model[0].length : model.length;

  int operator [](int k) => column ? model[k][which] : model[which][k];

  operator []=(int k, int value) {
    if (column) {
      model[k][which] = value;
    } else {
      model[which][k] = value;
    }
  }
}
