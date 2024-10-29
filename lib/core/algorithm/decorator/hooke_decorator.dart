// Copyright (c) 2024- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

/// Construct a decorative device with spring force between connected nodes.
///
/// 在相连节点间构建弹簧力的装饰器。
class HookeDecorator extends ForceDecorator {
  double length;
  double k;
  double Function(double length, int degree)? degreeFactor;

  @override
  Widget Function()? get verticalOverlay =>
      handleOverlay != null ? () => handleOverlay!(this) : null;

  Widget Function(HookeDecorator)? handleOverlay;

  HookeDecorator({
    this.length = 100,
    this.k = 0.003,
    super.decorators,
    super.sameTagsFactor = 1,
    this.handleOverlay,
    this.degreeFactor,
  });

  Vector2 hooke(Vertex s, Vertex d, Graph graph) {
    var len = degreeFactor?.call(length, d.neighborEdges.length) ?? length;
    var delta = s.cpn!.position - d.cpn!.position;
    var distance = delta.length;
    var force = -(distance - len - log(s.degree + d.degree)) * k;
    return delta * force;
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
