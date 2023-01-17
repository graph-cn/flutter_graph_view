// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_graph_view/flutter_graph_view.dart';

void main() {
  var forceDirected = ForceDirected();
  test('adds one to input values', () {
    for (var i = 0; i < 100; i++) {
      Vector2 v = forceDirected.randomInCircle(Offset.zero, 1, 0);
      print(v);

      expect(v.x < 1 && v.y < 1 && v.x > -1 && v.y > -1, true);
    }
  });
}
