// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:math' as math;
import 'package:flutter_graph_view/flutter_graph_view.dart';

/// Common tools.
///
/// 常用工具类
class Util {
  /// Compute distance between two point.
  ///
  /// 计算两点间的距离。
  static distance(Vector2 p1, Vector2 p2) {
    return math.sqrt(
      math.pow((p1.x) - (p2.x), 2) + math.pow((p1.y) - (p2.y), 2),
    );
  }
}
