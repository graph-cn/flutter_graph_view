// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:flutter_graph_view/core/graph_algorithm.dart';
import 'package:flutter_graph_view/model/vertex.dart';
import 'package:flutter_graph_view/model/graph.dart';
import 'dart:math' as math;

/// Breathe Decorator
///
/// 呼吸特效装饰器
@Deprecated("Already broken in version 1.1.4, will be removed in version 1.2.0")
class BreatheDecorator extends GraphAlgorithm {
  BreatheDecorator({super.decorators});
  @override
  void onLoad(Vertex v) {
    super.onLoad(v);
    v.cpn?.properties.putIfAbsent('breatheCount', () => 0);
    v.cpn?.properties.putIfAbsent('breatheDirect', math.Random().nextBool);
    v.cpn?.properties.putIfAbsent('breatheOffsetY', () => 0);
  }

  setBreatheCount(Vertex v, int value) =>
      v.cpn!.properties['breatheCount'] = value;
  setBreatheDirect(Vertex v, bool value) =>
      v.cpn!.properties['breatheDirect'] = value;
  setBreatheOffsetY(Vertex v, int value) =>
      v.cpn!.properties['breatheOffsetY'] = value;

  @override
  void compute(Vertex v, Graph graph) {
    super.compute(v, graph);
    if (v.cpn!.properties['breatheCount'] % 150 == 0) {
      v.cpn!.properties['breatheDirect'] = !v.cpn!.properties['breatheDirect'];
      v.cpn!.properties['breatheOffsetY'] =
          (v.cpn!.properties['breatheDirect'] ? 1 : -1) * .1;
    }
    if (v != graph.hoverVertex) {
      v.position.y += v.cpn!.properties['breatheOffsetY'];
    }
    v.cpn!.properties['breatheCount'] += 1;
  }
}
