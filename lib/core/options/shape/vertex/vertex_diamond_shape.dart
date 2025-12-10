
import 'dart:ui' as ui;
import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter_graph_view/flutter_graph_view.dart';

class VertexDiamondShape extends VertexShape {
  VertexDiamondShape({VertexTextRenderer? textRenderer, super.decorators}) {
    super.textRenderer = textRenderer ?? VertexTextRendererImpl(shape: this);
  }

  @override
  render(Vertex vertex, ui.Canvas canvas, paint, paintLayers) {
    // Draw a diamond (square rotated 45deg) with rounded corners.

    final double r = vertex.radiusZoom;
    final double s = r * math.sqrt2;
    final rect = Rect.fromCenter(center: ui.Offset.zero, width: s, height: s);
    final double cornerRadius = math.min(r * 0.35, r * 0.6);
    
    final double cornerRadiusClamped = math.min(cornerRadius, s / 2);
    final RRect rrect = RRect.fromRectAndRadius(rect, Radius.circular(cornerRadiusClamped));
    
    canvas.save();
    canvas.rotate(math.pi / 4);
    canvas.drawRRect(rrect, paint);
    canvas.restore();

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
