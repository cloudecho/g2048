import 'dart:ffi';

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

  void _swipe(void Function(int) swipeAction) {
    for (var k = 0; k < size; k++) {
      swipeAction(k);
    }
    _nextNum();
  }

  void _swipeLeft(final int i) {
    // remove zeros
    var nums = _nonZeros(_model[i]).toList(growable: false);
    // merge numbers
    _mergeNumbers(nums);
    nums = _nonZeros(nums).toList(growable: false);
    // update model
    if (_checkUpdate(nums)) {
      for (var j = 0; j < size; j++) {
        _model[i][j] = j < nums.length ? nums[j] : 0;
      }
    }
  }

  void _swipeRight(final int i) {
    // remove zeros
    var nums = _nonZeros(_model[i]).toList(growable: false);
    // merge numbers
    _mergeNumbers(nums, reserve: true);
    nums = _nonZeros(nums).toList(growable: false);
    // update model
    if (_checkUpdate(nums)) {
      for (var j = size - 1, k = nums.length - 1; j >= 0; j--, k--) {
        _model[i][j] = k >= 0 ? nums[k] : 0;
      }
    }
  }

  void _swipeUp(final int j) {
    // remove zeros
    var nums = _nonZerosAtColumn(j);
    // merge numbers
    _mergeNumbers(nums);
    nums = _nonZeros(nums).toList(growable: false);
    // update model
    if (_checkUpdate(nums)) {
      for (var i = 0; i < size; i++) {
        _model[i][j] = i < nums.length ? nums[i] : 0;
      }
    }
  }

  void _swipeDown(final int j) {
    // remove zeros
    var nums = _nonZerosAtColumn(j);
    // merge numbers
    _mergeNumbers(nums, reserve: true);
    nums = _nonZeros(nums).toList(growable: false);
    // update model
    if (_checkUpdate(nums)) {
      for (var i = size - 1, k = nums.length - 1; i >= 0; i--, k--) {
        _model[i][j] = k >= 0 ? nums[k] : 0;
      }
    }
  }

  bool _checkUpdate(List<int> nums) => nums.isNotEmpty && nums.length < size;

  List<int> _nonZerosAtColumn(int j) {
    var nums = <int>[];
    for (var i = 0; i < size; i++) {
      if (_model[i][j] > 0) nums.add(_model[i][j]);
    }
    return nums;
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

  Iterable<int> _nonZeros(Iterable<int> nums) => nums.where((e) => e != 0);

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
    _newPostion = p;
    notifyListeners();
    return true;
  }

  Point? _newPostion;
}
