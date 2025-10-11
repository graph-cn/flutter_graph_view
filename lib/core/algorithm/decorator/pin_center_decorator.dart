// Copyright (c) 2024- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:flutter_graph_view/flutter_graph_view.dart';

/// Pin the center point of the subgraph to prevent it from moving
///
/// 固定子图的度最多的节点，防止其移动的装饰器
class PinCenterDecorator extends ForceDecorator {
  PinCenterDecorator();
  @override
  // ignore: must_call_super
  void compute(Vertex v, Graph graph) {
    if (v.isCenter) {
      getForceMap(v).forEach((key, forces) {
        forces.forEach((key, value) {
          forces[key] = Vector2.zero();
        });
      });
    }
  }
}
