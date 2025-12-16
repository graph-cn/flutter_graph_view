// Copyright (c) 2025- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:math';

import 'package:flutter_graph_view/flutter_graph_view.dart';

/// 希望表间的顺序从左到右
@Deprecated('beta, to be complete')
class HorizontalHookeDecorator extends ForceDecorator {
  double k;
  HorizontalHookeDecorator({this.k = 1, super.sameTagsFactor = 1});

  Vector2 hooke(Vertex s, Vertex d, Graph graph) {
    if (s.position.x < d.position.x) return Vector2.zero();
    var sp = Vector2(s.position.x, 0);
    var dp = Vector2(d.position.x, 0);
    var len = sp.distanceTo(dp);
    var delta = sp - dp;
    var distance = delta.length;
    var force = -(distance - len - log(s.degree + d.degree)) * k;
    return delta * force;
  }

  @override
  // ignore: must_call_super
  void compute(Vertex v, Graph graph) {
    for (var b in graph.vertexes) {
      if (v != b &&
          v.position != Vector2.zero() &&
          b.position != Vector2.zero()) {
        // F = k * q1 * q2 / r^2
        if (v.nextVertexes.contains(b) || b.neighbors.contains(v)) {
          var f = hooke(v, b, graph);
          setForceMap(v, b, f);
        }
      }
    }
  }
}
