// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:math' as math;

import 'package:flutter_graph_view/flutter_graph_view.dart';

/// for test.
class RandomAlgorithm extends GraphAlgorithm {
  RandomAlgorithm() : super(null);

  @override
  void compute(Vertex v, Graph graph) {
    if (v.position == Vector2(0, 0)) {
      v.radius = math.log(v.degree * 10 + 1) + 5;
      v.position = Vector2(math.Random().nextDouble() * (size!.width - 50) + 25,
          math.Random().nextDouble() * (size!.height - 50) + 25);
    }
  }

  @override
  void onZoomVertex(Vertex vertex, Vector2 pointLocation, double delta) {
    // if (vertex.cpn?.isHovered ?? false) return;
    // var vp = vertex.position;
    // var zoomRate = delta > 0 ? 2 : -2; // delta > 0 缩小，delta < 0 放大
    // var dx = (pointLocation.x - vp.x) / zoomRate;
    // var dy = (pointLocation.y - vp.y) / zoomRate;
    // vp.x += dx;
    // vp.y += dy;
    // vertex.radius -= delta > 0 ? .1 : -.1;
  }
}
