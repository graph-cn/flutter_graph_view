// Copyright (c) 2024- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:flutter_graph_view/flutter_graph_view.dart';

/// Pin the points that have been dragged in the fixed graph, preventing them from moving
///
/// 固定图中被拖拽过的点，防止其移动的装饰器
class PinDecorator extends ForceDecorator {
  final Set<dynamic> pinned = {};
  PinDecorator({super.decorators});

  @override
  void afterDrag(Vertex vertex, Vector2 globalDelta) {
    super.afterDrag(vertex, globalDelta);
    pinned.add(vertex.id);
  }

  @override
  bool needContinue(Vertex v) {
    if (pinned.contains(v.id)) {
      return false;
    } else {
      return true;
    }
  }
}
