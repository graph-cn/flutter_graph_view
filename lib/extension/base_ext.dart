// Copyright (c) 2025- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:ui' as ui;

import 'package:vector_math/vector_math.dart' show Vector2;

extension SizeExt on ui.Size {
  Vector2 toVector2() => Vector2(width, height);
}

extension Vector2Ext on Vector2 {
  ui.Offset toOffset() => ui.Offset(x, y);
}

extension OffsetExt on ui.Offset {
  Vector2 toVector2() => Vector2(dx, dy);
}
