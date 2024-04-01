// Copyright (c) 2024- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:math';

import 'package:flutter_graph_view/flutter_graph_view.dart';

/// Construct a decorative device with spring force between connected nodes.
///
/// 在相连节点间构建弹簧力的装饰器。
class HookeDecorator extends ForceDecorator {
  double length;
  double k;
  HookeDecorator({
    this.length = 100,
    this.k = 0.003,
    super.decorators,
  });

  Vector2 hooke(Vertex s, Vertex d, Graph graph) {
    if (d.degree >= s.degree || graph.hoverVertex == d) {
      var delta = s.position - d.position;
      var distance = delta.length;
      var force = -(distance - length - log(s.degree + d.degree)) * k;
      return delta * force;
    }
    return Vector2.zero();
  }

  @override
  void compute(Vertex v, Graph graph) {
    super.compute(v, graph);
    for (var n in v.neighbors) {
      if (v.position != Vector2.zero() && n.position != Vector2.zero()) {
        var force = hooke(v, n, graph);
        setForceMap(v, n, force);
      }
    }
  }
}
