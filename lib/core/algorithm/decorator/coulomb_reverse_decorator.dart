// Copyright (c) 2024- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

/// The reverse usage of Coulomb's law,
/// The more the degree, the less the charge, and the weaker the mutual exclusion.
///
/// 库仑定律的反向用法，度越多，带电越少，互斥力越弱
class CoulombReverseDecorator extends ForceDecorator {
  double k;

  Widget Function(CoulombReverseDecorator)? handleOverlay;

  @override
  Widget Function()? get verticalOverlay =>
      handleOverlay != null ? () => handleOverlay!(this) : null;

  CoulombReverseDecorator({
    this.k = 100000,
    this.handleOverlay,
    super.sameSrcAndDstFactor = 1,
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
        var delta = v.position - b.position;
        var distance = delta.length;
        var force =
            k * (1 / v.radius) * (1 / b.radius) / max((distance * distance), 1);
        var f = delta * force;
        f = f * computeSameSrcAndDstFactor(v, b);
        setForceMap(v, b, f);
      }
    }
  }
}
