// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:math' as math;

import 'package:flutter_graph_view/flutter_graph_view.dart';

/// for test.
class RandomAlgorithm extends GraphAlgorithm {
  RandomAlgorithm() : super(null);

  @override
  void compute(Vertex element, Graph graph) {
    if (element.position == Vector2(0, 0)) {
      element.radius = math.log(element.degree * 10 + 1) + 5;
      element.position = Vector2(
          math.Random().nextDouble() * (size!.width - 50) + 25,
          math.Random().nextDouble() * (size!.height - 50) + 25);
    }
  }
}
