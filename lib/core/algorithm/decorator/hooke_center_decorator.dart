// Copyright (c) 2024- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:flutter_graph_view/flutter_graph_view.dart';

/// Hook force from the center point outward,
/// pushing the node towards the decorative device of the field of view boundary
///
/// 从中心点向外的胡克力，将节点推向视野边界的装饰器
class HookeCenterDecorator extends ForceDecorator {
  double length;
  double k;
  HookeCenterDecorator({
    this.length = 1,
    this.k = 0.003,
  });

  Vector2 hooke(Vertex s, Graph graph) {
    var size = graph.size.value;
    var center = Vector2(size.width, size.height) / 2;

    var delta = s.position - center;
    var distance = delta.length;
    if (distance == 0) return Vector2(1, 1);
    var force = -(distance - length) * k;
    return delta * force;
  }

  @override
  // ignore: must_call_super
  void compute(Vertex v, Graph graph) {
    if (v.position != Vector2.zero()) {
      var force = hooke(v, graph);
      setForceMap(v, v, force);
    }
  }
}
