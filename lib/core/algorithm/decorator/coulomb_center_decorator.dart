// Copyright (c) 2024- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:flutter_graph_view/flutter_graph_view.dart';

/// Decorator which the magnitude of the central repulsive
/// force on a node is inversely proportional to its own degree
///
/// 节点受到中心排斥力大小与自身度呈反比的装饰器
class CoulombCenterDecorator extends ForceDecorator {
  double k;
  CoulombCenterDecorator({this.k = 100});

  @override
  // ignore: must_call_super
  void compute(Vertex v, Graph graph) {
    var center = v.cpn!.game.size / 2;

    var delta = v.position - center;
    if (delta != Vector2.zero()) {
      var distance = delta.length;
      var force = k * (1 / v.radius) * (1 / v.radius) / distance * distance;
      var f = delta * force;
      setForceMap(v, v, f);
    }
  }
}
