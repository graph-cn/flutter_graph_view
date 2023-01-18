// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

///
/// Force oriented map layout algorithm.
/// 力导向图布局算法
///
class ForceDirected extends GraphAlgorithm {
  ForceDirected([decorate]) : super(decorate);

  @override
  void compute(
    Vertex v,
    Graph graph, [
    Offset? c,
    int deep = 1,
  ]) {
    if (v.position == Vector2(0, 0)) {
      var ct = c ?? center / 2;
      v.position = randomInCircle(ct, 1 / deep * offset, v.radius);

      var vchildren = <Vertex>[...v.nextVertexes, ...v.prevVertexes];
      for (var n in vchildren) {
        compute(
          n,
          graph,
          Offset(v.position.x, v.position.y),
          deep + 1,
        );
      }
    }
  }

  Random random = Random();

  ///
  /// Generates random positions in a specific circle.
  /// 在一个指定的圆周区域内生成随机位置
  ///
  Vector2 randomInCircle(Offset center, double distance, double rOffset) {
    var dr = random.nextDouble() * distance;
    var angle = random.nextDouble() * pi;
    var s = sin(angle);
    var c = cos(angle);

    double x, y;

    var dx = dr * c * (random.nextBool() ? 1 : -1);
    var dy = dr * s * (random.nextBool() ? 1 : -1);

    x = center.dx + dx;
    y = center.dy + dy;

    return Vector2(x, y);
  }
}
