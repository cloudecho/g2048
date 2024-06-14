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

  void _swipe(bool Function(int) swipeAction) async {
    // move zeros
    _resetNewPosition();
    var hasMoved = false;
    for (var i = 0; i < size; i++) {
      hasMoved |= swipeAction(i);
    }
    if (hasMoved) notifyListeners();

    // merge numbers
    await _sleep(kSlideMilliseconds);
    var gotScore = 0;
    for (var k = 0; k < size; k++) {
      final vertical = swipeAction == _swipeUp || swipeAction == _swipeDown;
      var nums = _nums(k, column: vertical);
      gotScore += _mergeNumbers(
        nums,
        reserve: swipeAction == _swipeRight || swipeAction == _swipeDown,
      );
      swipeAction(k);
    }

    // score & next number
    if (hasMoved || gotScore > 0) {
      score += gotScore;
      _nextNum();
      _checkDone();
      notifyListeners();
    }
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

  bool _swipeLeft(final int i) {
    var hasMoved = false;
    var moves = _moveZeros(_nums(i));
    for (var k = 0; k < size; k++) {
      hasMoved |= moves[k] > 0;
      _offsets[i][k] = Offset(moves[k].toDouble(), 0);
    }
    return hasMoved;
  }

  bool _swipeRight(final int i) {
    var hasMoved = false;
    var moves = _moveZeros(_nums(i), reverse: true);
    for (var k = 0; k < size; k++) {
      hasMoved |= moves[k] > 0;
      _offsets[i][k] = Offset(-moves[k].toDouble(), 0);
    }
    return hasMoved;
  }

  bool _swipeUp(final int j) {
    var hasMoved = false;
    var nums = _numsAtColumn(j);
    var moves = _moveZeros(nums);
    for (var k = 0; k < size; k++) {
      hasMoved |= moves[k] > 0;
      _offsets[k][j] = Offset(0, moves[k].toDouble());
    }
    return hasMoved;
  }

  bool _swipeDown(final int j) {
    var hasMoved = false;
    var nums = _numsAtColumn(j);
    var moves = _moveZeros(nums, reverse: true);
    for (var k = 0; k < size; k++) {
      hasMoved |= moves[k] > 0;
      _offsets[k][j] = Offset(0, -moves[k].toDouble());
    }
    return hasMoved;
  }

  /// Merge the adjacent non-zero number into a bigger one,
  /// from left to right if [reserve] is `false`,
  /// or from right to left if [reserve] is `true`.
  /// Return the score to be accumulated.
  int _mergeNumbers(Nums nums, {bool reserve = false}) {
    var gotScore = 0;
    if (reserve) {
      for (var k = nums.length - 1; k > 0; k--) {
        if (nums[k] == 0) continue;
        if (nums[k] == nums[k - 1]) {
          nums[k] *= 2;
          nums[k - 1] = 0;
          gotScore += nums[k];
        }
      }
    } else {
      for (var k = 0; k < nums.length - 1; k++) {
        if (nums[k] == 0) continue;
        if (nums[k] == nums[k + 1]) {
          nums[k] *= 2;
          nums[k + 1] = 0;
          gotScore += nums[k];
        }
      }
    }
    return gotScore;
  }

  /// Move the non-zero numbers to the left side if [reverse] is false,
  /// or to the right side if [reverse] is `true`
  List<int> _moveZeros(Nums nums, {bool reverse = false}) {
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
    return moves;
  }

  static final _rand = math.Random();

  Point? _newPostion;

  void _nextNum() {
    List<Point> points = [];
    for (var i = 0; i < size; i++) {
      for (var j = 0; j < size; j++) {
        if (0 == _model[i][j]) points.add((x: i, y: j));
      }
    }
    if (points.isEmpty) return;

    var p = points[_rand.nextInt(points.length)];
    _model[p.x][p.y] = _rand.nextDouble() < 0.1 ? 4 : 2;
    _newPostion = p;
  }

  bool isNewPosition(int x, int y) {
    return _newPostion == (x: x, y: y);
  }

  Nums _numsAtColumn(int j) => _nums(j, column: true);

  Nums _nums(int which, {bool column = false}) =>
      Nums(_model, which, column: column);
}

/// The view of the numbers in a row or a column
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
