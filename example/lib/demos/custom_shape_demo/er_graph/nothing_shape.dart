// Copyright (c) 2025- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

// ignore_for_file: depend_on_referenced_packages

import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

class NothingEdgeShape extends EdgeShape {
  @override
  double height(Edge edge) {
    return 0;
  }

  @override
  ShapeHitbox? hitBox(Edge edge, EdgeComponent edgeComponent) {
    return RectangleHitbox(
      size: Vector2.zero(),
      isSolid: true,
      position: edgeComponent.position,
      anchor: edgeComponent.anchor,
    );
  }

  @override
  render(Edge edge, Canvas canvas, Paint paint, List<Paint> paintLayers) {}

  @override
  void setPaint(Edge edge) {}
}

class NothingShape extends VertexShape {
  @override
  double height(Vertex vertex) {
    return (vertex.cpn?.size.x ?? 0.0) / 2;
  }

  @override
  double width(Vertex vertex) {
    return (vertex.cpn?.size.y ?? 0.0) / 2;
  }

  @override
  ShapeHitbox hitBox(Vertex vertex, ShapeComponent cpn) {
    return RectangleHitbox(
      size: Vector2.zero(),
      isSolid: true,
      position: cpn.position,
      anchor: cpn.anchor,
    );
  }

  @override
  render(Vertex vertex, Canvas canvas, Paint paint, List<Paint> paintLayers) {}

  @override
  void setPaint(Vertex vertex) {
    // TODO: implement setPaint
  }

  @override
  void updateHitBox(Vertex vertex, ShapeHitbox hitBox) {
    // TODO: implement updateHitBox
  }
}
