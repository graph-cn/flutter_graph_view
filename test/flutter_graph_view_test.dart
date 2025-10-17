// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

double shiftedLn(double x) {
  return log(x + 1) / log(11);
}

void main() {
  test('adds one to input values', () {
    print(log(0.0005 * e));
    print(log(0.5 * e));
    print(log(e));
    print(log(2 * e));
  });

  test('test', () {
    print('x = 0.1: ${shiftedLn(0.1)}'); // ≈ 0.040
    print('x = 1: ${shiftedLn(1)}'); // ≈ 0.289
    print('x = 10: ${shiftedLn(10)}'); // 1.0

    // 可视化验证
    for (double x = 0.1; x <= 20; x += 1) {
      print(
          'x = ${x.toStringAsFixed(1)}: y = ${shiftedLn(x).toStringAsFixed(3)}');
    }
  });
}
