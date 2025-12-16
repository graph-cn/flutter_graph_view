// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter_graph_view/flutter_graph_view.dart';

/// The default shape impl.
///
/// 默认使用 圆型做节点。
class VertexCircleShape extends VertexShape {
  VertexCircleShape({VertexTextRenderer? textRenderer, super.decorators}) {
    super.textRenderer = textRenderer ?? VertexTextRendererImpl(shape: this);
  }

  @override
  render(Vertex vertex, ui.Canvas canvas, paint, paintLayers) {
    canvas.drawCircle(
      const ui.Offset(0, 0),
      vertex.radiusZoom,
      paint,
    );
    // 渲染标题
    if (vertex.g?.options?.showText ?? true && vertex.zoom > 0.3) {
      textRenderer?.render(vertex, canvas, paint);
    }
    decorators?.forEach((decorator) {
      decorator.decorate(vertex, canvas, paint, paintLayers);
    });
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
  Paint getPaint(Vertex vertex) {
    Paint paint = Paint();
    var colors = vertex.colors;

    if (vertex.solid) {
      paint.color = vertex.colors.first;
      return paint;
    }

    if (isWeaken(vertex)) {
      var hoverOpacity = vertex.g?.options?.graphStyle.hoverOpacity ?? 1.0;
      paint.shader = ui.Gradient.radial(
        ui.Offset.zero,
        vertex.radiusZoom,
        List.generate(
          colors.length,
          (index) => colors[index].withValues(alpha: hoverOpacity),
        ),
        List.generate(colors.length, (index) => (index + 1) / colors.length),
      );
    } else {
      paint.shader = ui.Gradient.radial(
        ui.Offset.zero,
        vertex.radiusZoom,
        colors,
        List.generate(colors.length, (index) => (index + 1) / colors.length),
      );
    }
    return paint;
  }
}
