// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

/// Randomly generate node positions in the field of view during loading
///
/// 在加载时，在视野中随机生成节点的位置
class RandomAlgorithm extends GraphAlgorithm {
  RandomAlgorithm({super.decorators});

  @override
  void onLoad(Vertex v) {
    if (v.position == Vector2(0, 0)) {
      var size = graph?.options?.visibleWorldRect ??
          const Rect.fromLTWH(0, 0, 1920, 1080);
      v.position = Vector2(math.Random().nextDouble() * (size.width - 50) + 25,
          math.Random().nextDouble() * (size.height - 50) + 25);
    }
    super.onLoad(v);
  }
}
