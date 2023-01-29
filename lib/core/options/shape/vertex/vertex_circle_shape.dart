// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

/// The default shape impl.
///
/// 默认使用 圆型做节点。
class VertexCircleShape extends VertexShape {
  @override
  render(Vertex vertex, Canvas canvas, paint, paintLayers) {
    canvas.drawCircle(
      Offset(vertex.radius, vertex.radius),
      vertex.radius,
      paint,
    );
  }

  @override
  double height(Vertex vertex) {
    return vertex.radius * 2;
  }

  @override
  double width(Vertex vertex) {
    return vertex.radius * 2;
  }

  @override
  ShapeHitbox hitBox(Vertex vertex, ShapeComponent cpn) {
    return CircleHitbox(
      isSolid: true,
      position: cpn.position,
      anchor: cpn.anchor,
    );
  }

  @override
  void updateHitBox(Vertex vertex, ShapeHitbox hitBox) {
    hitBox as CircleHitbox;
    hitBox.radius = vertex.radius * 2;
  }

  @override
  void setPaint(Vertex vertex) {
    var cpn = vertex.cpn!;
    if (isWeaken(vertex)) {
      cpn.paint = Paint()
        ..shader = Gradient.radial(
          Offset(vertex.radius, vertex.radius),
          vertex.radius,
          List.generate(
            vertex.colors.length,
            (index) => vertex.colors[index].withOpacity(.5),
          ),
        );
    } else {
      cpn.paint = Paint()
        ..shader = Gradient.radial(
          Offset(vertex.radius, vertex.radius),
          vertex.radius,
          vertex.colors,
        );
    }
  }
}
