// Copyright (c) 2024- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:flutter_graph_view/flutter_graph_view.dart';

/// Decorator that converts the force of vertices into motion velocity
/// and changes the position of nodes
///
/// 将顶点的力转换成运动速度并改变节点位置的装饰器。
class ForceMotionDecorator extends GraphAlgorithm {
  int unitTime;
  ForceMotionDecorator({this.unitTime = 1, super.decorators});

  Vector2 getForce(Vertex v) {
    var force = v.cpn!.properties['force'] as Vector2?;
    return force ?? Vector2.zero();
  }

  int getTimeCounter(Vertex v) {
    var timeCounter = v.cpn!.properties['timeCounter'] as int?;
    return timeCounter ?? -1;
  }

  @override
  void compute(Vertex v, Graph graph) {
    super.compute(v, graph);
    int timeCounter = getTimeCounter(v);
    if (timeCounter % unitTime == 0) {
      if (v != graph.hoverVertex) {
        // F = m * a
        var f = getForce(v);
        var a = f / v.radius;
        if (a.x.isNaN || a.y.isNaN) {
          return;
        } else {
          // s = 1/2 * a * t^2
          var s = a * 0.5 * unitTime.toDouble();
          v.position += s;
        }
      }
    }
  }
}
