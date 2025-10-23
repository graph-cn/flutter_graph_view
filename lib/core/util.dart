// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:ui';

import 'package:flutter_graph_view/flutter_graph_view.dart';

/// Common tools.
///
/// 常用工具类
class Util {
  /// Compute distance between two point.
  ///
  /// 计算两点间的距离。
  static distance(Vector2 p1, Vector2 p2) {
    return (p1 - p2).length;
  }

  // Type cast.
  @Deprecated('Please use `v?.toOffset()` insteads of')
  static Offset? toOffsetByVector2(Vector2? v) {
    return v == null ? null : Offset(v.x, v.y);
  }
}
