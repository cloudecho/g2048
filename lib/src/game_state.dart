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
      var nums = vertical ? _numsAtColumn(k) : _model[k];
      _mergeNumbers(
        nums,
        reserve: swipeAction == _swipeRight || swipeAction == _swipeDown,
      );
      if (vertical) _updateColumn(k, nums);
      swipeAction(k);
    }
    _nextNum();
    _checkDone();
    notifyListeners();
  }

  void _checkDone() {
    for (var k = 0; k < size; k++) {
      if (!_isDone(_model[k]) || !_isDone(_numsAtColumn(k))) {
        return;
      }
    }
    done = true;
  }

  bool _isDone(List<int> nums) {
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
    var moves = _removeZeros(_model[i]);
    for (var k = 0; k < size; k++) {
      _offsets[i][k] = Offset(moves[k].toDouble(), 0);
    }
  }

  void _swipeRight(final int i) {
    var moves = _removeZeros(_model[i], reverse: true);
    for (var k = 0; k < size; k++) {
      _offsets[i][k] = Offset(-moves[k].toDouble(), 0);
    }
  }

  void _swipeUp(final int j) {
    var nums = _numsAtColumn(j);
    var moves = _removeZeros(nums);
    _updateColumn(j, nums);
    for (var k = 0; k < size; k++) {
      _offsets[k][j] = Offset(0, moves[k].toDouble());
    }
  }

  void _swipeDown(final int j) {
    var nums = _numsAtColumn(j);
    var moves = _removeZeros(nums, reverse: true);
    _updateColumn(j, nums);
    for (var k = 0; k < size; k++) {
      _offsets[k][j] = Offset(0, -moves[k].toDouble());
    }
  }

  List<int> _numsAtColumn(int j) {
    var nums = <int>[];
    for (var i = 0; i < size; i++) {
      nums.add(_model[i][j]);
    }
    return nums;
  }

  void _updateColumn(final int j, final List<int> nums) {
    for (var i = 0; i < size; i++) {
      _model[i][j] = nums[i];
    }
  }

  void _mergeNumbers(List<int> nums, {bool reserve = false}) {
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

  List<int> _removeZeros(List<int> nums, {bool reverse = false}) {
    var moves = List.filled(nums.length, 0, growable: false);
    if (reverse) {
      for (var k = nums.length - 2; k >= 0; k--) {
        if (nums[k] == 0) continue;
        var count = 0, i = k + 1;
        for (; i < nums.length; i++) {
          if (nums[i] == 0) {
            nums[i] = nums[i - 1];
            nums[i - 1] = 0;
            count++;
          } else {
            // no zero anymore
            break;
          }
        }
        moves[i - 1] = count;
      }
    } else {
      for (var k = 1; k < nums.length; k++) {
        if (nums[k] == 0) continue;
        var count = 0, i = k - 1;
        for (; i >= 0; i--) {
          if (nums[i] == 0) {
            nums[i] = nums[i + 1];
            nums[i + 1] = 0;
            count++;
          } else {
            // no zero anymore
            break;
          }
        }
        moves[i + 1] = count;
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
}
