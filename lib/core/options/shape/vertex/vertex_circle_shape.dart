// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:ui' as ui;

import 'package:flame/collisions.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

/// The default shape impl.
///
/// 默认使用 圆型做节点。
class VertexCircleShape extends VertexShape {
  VertexCircleShape({VertexTextRenderer? textRenderer}) {
    super.textRenderer = textRenderer ?? VertexTextRendererImpl();
  }

  @override
  render(Vertex vertex, ui.Canvas canvas, paint, paintLayers) {
    canvas.drawCircle(
      ui.Offset(vertex.radiusZoom, vertex.radiusZoom),
      vertex.radiusZoom,
      paint,
    );
    // 渲染标题
    if (vertex.cpn?.options?.showText ??
        true && vertex.cpn!.game.camera.viewfinder.zoom > 0.3) {
      textRenderer?.render(vertex, canvas, paint);
    }
  }

  @override
  double height(Vertex vertex) {
    return vertex.radiusZoom * 2;
  }

  @override
  double width(Vertex vertex) {
    return vertex.radiusZoom * 2;
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
    hitBox.radius = vertex.radiusZoom * 2;
  }

  @override
  void setPaint(Vertex vertex) {
    var cpn = vertex.cpn!;
    var colors = vertex.colors;

    if (isWeaken(vertex)) {
      cpn.paint = ui.Paint()
        ..shader = ui.Gradient.radial(
          ui.Offset(vertex.radiusZoom, vertex.radiusZoom),
          vertex.radiusZoom,
          List.generate(
            colors.length,
            (index) => colors[index].withOpacity(.3),
          ),
          List.generate(colors.length, (index) => (index + 1) / colors.length),
        );
    } else {
      cpn.paint = ui.Paint()
        ..shader = ui.Gradient.radial(
          ui.Offset(vertex.radiusZoom, vertex.radiusZoom),
          vertex.radiusZoom,
          colors,
          List.generate(colors.length, (index) => (index + 1) / colors.length),
        );
    }
  }
}
