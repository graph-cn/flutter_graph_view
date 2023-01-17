// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:math';

import 'package:flutter_graph_view/flutter_graph_view.dart';

/// for test.
class RandomAlgorithm implements GraphAlgorithm {
  RandomAlgorithm();

  @override
  void compute(Vertex element, Set<Vertex> vertexes, Set<Edge> edges) {
    element.position = Vector2(
        Random().nextDouble() * 1440 + 20, Random().nextDouble() * 700 + 20);
    element.radius = Random().nextInt(15) + 5;
  }
}
