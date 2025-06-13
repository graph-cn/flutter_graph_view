// Copyright (c) 2024- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:flutter_graph_view/flutter_graph_view.dart';

/// Decorators with the highest degree among nodes in a subgraph that repel each other.
///
/// 子图中，度最多的节点间相互排斥的装饰器（库仑定律）
@Deprecated('An experimental method')
class CoulombBorderDecorator extends ForceDecorator {
  double k;
  CoulombBorderDecorator({
    this.k = 1,
    super.decorators,
  });

  @override
  void compute(Vertex v, Graph graph) {
    super.compute(v, graph);
    var size = v.cpn!.game.size;

    var corner = [
      Vector2(0, 0),
      Vector2(0, size.y),
      Vector2(size.x, size.y),
      Vector2(size.x, 0),
      Vector2(0, size.y / 2),
      Vector2(size.x / 2, size.y),
      Vector2(size.x, size.y / 2),
      Vector2(size.x / 2, 0),
    ];
    for (var b in corner) {
      if (v.position != Vector2.zero()) {
        // F = k * q1 * q2 / r^2
        var delta = v.position - b;
        var distance = delta.length;
        if (distance != 0) {
          var force = k * v.radius * v.radius / distance * distance;
          var f = delta * force;
          setForceMap(v, v, f);
        }
      }
    }
  }
}
