// Copyright (c) 2024- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:math';

import 'package:flutter_graph_view/flutter_graph_view.dart';

/// Decorators in which all nodes in the figure form repulsive interactions with each other.
///
/// 图中所有节点相互间形成排斥的装饰器（库仑力）
class CoulombDecorator extends ForceDecorator {
  double k;
  CoulombDecorator({
    this.k = 10,
    super.sameTagsFactor = 1,
    super.decorators,
  });

  @override
  void compute(Vertex v, Graph graph) {
    super.compute(v, graph);
    for (var b in graph.vertexes) {
      if (v != b &&
          v.position != Vector2.zero() &&
          b.position != Vector2.zero()) {
        // F = k * q1 * q2 / r^2
        var delta = v.position - b.position;
        var distance = delta.length;
        var force = k * v.radius * b.radius / max((distance * distance), 1);
        var f = delta * force;
        setForceMap(v, b, f);
      }
    }
  }
}
