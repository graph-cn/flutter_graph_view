// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_graph_view/core/util.dart';
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
    Graph graph,
  ) {
    if (v.position == Vector2(0, 0)) {
      var ct = Util.toOffsetByVector2(v.prevVertex?.position) ?? center / 2;
      var distanceFromCenter = 1 / v.deep * offset;
      var noAllowCircleRadius = .3 * distanceFromCenter;
      v.position = randomInCircle(ct, distanceFromCenter, noAllowCircleRadius);

      for (var n in v.nextVertexes) {
        if (n.prevVertex == null) {
          n.prevVertex = v;
          n.deep = v.deep + 1;
        }
      }
    }

    // Keep children vertexes around the parent vertex.
    if (v.prevVertex != null) {
      if (Util.distance(v.position, v.prevVertex!.position) <
          5 * v.prevVertex!.radius) {
        v.position += (v.position - v.prevVertex!.position) / 100;
      } else if (Util.distance(v.position, v.prevVertex!.position) >
          20 * v.prevVertex!.radius) {
        v.position -= (v.position - v.prevVertex!.position) / 100;
      }
    }
  }

  Random random = Random();

  ///
  /// Generates random positions in a specific circle.
  /// 在一个指定的圆周区域内生成随机位置
  ///
  Vector2 randomInCircle(Offset center, double distance, double rOffset) {
    var dr = random.nextDouble() * distance + rOffset;
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
