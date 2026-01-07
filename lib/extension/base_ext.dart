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

  Vector2 operator +(Vector2? other) =>
      other == null ? this : this + other
  ;
}

extension Vector2ExtNullable on Vector2? {
  Vector2 operator +(Vector2? other) =>
      this == null
          ? (other ?? Vector2.zero())
          : (other == null ? this! : this! + other)
  ;
}

extension OffsetExt on ui.Offset {
  Vector2 toVector2() => Vector2(dx, dy);
}



extension ForceMap<T> on Map<T,Vector2>{
  void addOrSet(T key, Vector2 val) {
    this[key] = containsKey(key)
        ? this[key]! + val
        : val;
  }
}

/// Used to represent a result of a Raw computation. the key is a Vertex ID
/// the value is a Vector2 representing a force, position, velocity, etc...
typedef ComputeRes = Map<String, Vector2>;