// Copyright (c) 2024- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:flutter_graph_view/flutter_graph_view.dart';

/// Decorators with the highest degree among nodes in a subgraph that repel each other.
///
/// 子图中，度最多的节点间相互排斥的装饰器（库仑定律）
class CoulombCenterDecorator extends ForceDecorator {
  double k;
  CoulombCenterDecorator({
    this.k = 0.001,
    super.decorators,
  });

  @override
  void compute(Vertex v, Graph graph) {
    super.compute(v, graph);
    for (var b in graph.centerVertexes) {
      if (v != b && v.prevVertex != v && v.position != Vector2.zero() ||
          b == graph.hoverVertex && v.position - b.position != Vector2.zero()) {
        // F = k * q1 * q2 / r^2
        var delta = v.position - b.position;
        var distance = delta.length;
        var force = k * v.radius * b.radius / distance * distance;
        var f = delta * force;
        setForceMap(v, b, f);
      }
    }
  }
}
