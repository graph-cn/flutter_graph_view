// Copyright (c) 2025- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:ui' as ui;

import 'package:flutter/rendering.dart' as r;
import 'package:vector_math/vector_math.dart' show Vector2;
import 'package:vector_math/vector_math_64.dart' show Vector3;

extension SizeExt on ui.Size {
  Vector2 toVector2() => Vector2(width, height);
  ui.Offset toOffset() => ui.Offset(width, height);
}

extension Vector2Ext on Vector2 {
  ui.Offset toOffset() => ui.Offset(x, y);

  r.Matrix4 toMatrix() {
    r.Matrix4 transformMatrix = r.Matrix4.identity();
    transformMatrix.translateByVector3(Vector3(x, y, 0));
    return transformMatrix;
  }
}

extension OffsetExt on ui.Offset {
  Vector2 toVector2() => Vector2(dx, dy);
}
