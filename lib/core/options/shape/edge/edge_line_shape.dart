// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_graph_view/core/util.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

/// The default edge shape impl.
///
/// 默认使用 直线做边。
class EdgeLineShape extends EdgeShape {
  final double scaleLoop;
  EdgeLineShape({this.scaleLoop = 1.0, super.decorators});

  @override
  render(Edge edge, Canvas canvas, Paint paint, List<Paint> paintLayers) {
    if (edge.isLoop) {
      vertexSame(edge, canvas, paint);
    } else {
      vertexDifferent(edge, canvas, paint);
    }
    decorators?.forEach((decorator) {
      decorator.decorate(edge, canvas, paint);
    });
  }

  void vertexDifferent(Edge edge, ui.Canvas canvas, ui.Paint paint) {
    var endPoint = Offset(len(edge), paint.strokeWidth);

    var distance = Util.distance(
      Vector2(0, 0),
      Vector2(endPoint.dx, 0),
    );

    var edgesBetweenTwoVertex = edge.g?.edgesFromTwoVertex(edge.start, edge.end) ?? [];

    var edgeCount = edgesBetweenTwoVertex.length;

    /// 法线点
    var normalPoint = Vector2(
      distance / 2,
      edge.computeIndex * distance / edgeCount * 2 + edge.size.y / 2,
    );

    if (normalPoint.isNaN) {
      return;
    }
    Path path = Path();
    path.moveTo(0, -paint.strokeWidth / edge.g!.options!.scale.value / 2);
    path.cubicTo(
      0,
      0,
      normalPoint.x,
      normalPoint.y,
      endPoint.dx,
      0,
    );
    // path.extendWithPath(path, Offset(0, paint.strokeWidth));
    edge.path = path;
    canvas.drawPath(path, paint);
  }

  void vertexSame(Edge edge, ui.Canvas canvas, ui.Paint paint) {
    Path path = loopPath(edge);
    canvas.drawPath(path, paint);
    edge.path = path;
  }

  @override
  Path loopPath(Edge edge, [double minusRadius = 0]) {
    var ratio = edge.edgeIdxRatio;
    var radius = (ratio * edge.start.radius * 5 + edge.start.radiusZoom) * scaleLoop;
    Path path = Path();
    path.addArc(
      Rect.fromCircle(center: Offset(radius, 0), radius: radius - minusRadius / edge.zoom),
      0,
      -2 * pi,
    );

    return path;
  }

  @override
  Paint getPaint(Edge edge) {
    var paint = Paint();
    paint.strokeWidth = (edge.isHovered ? 4 : 1.2) / edge.zoom;
    // paint.strokeWidth = edge.zoom;
    paint.style = PaintingStyle.stroke;
    var startPoint = Offset.zero;
    var endPoint = Offset(len(edge), paint.strokeWidth);
    var hoverOpacity = edge.g?.options?.graphStyle.hoverOpacity ?? .5;

    if (edge.solid) {
      paint.color = edge.start.colors.lastOrNull ?? Colors.white;
      
      return paint;
    }

    if (isWeaken(edge)) {
      paint.shader = ui.Gradient.linear(
        startPoint,
        endPoint,
        List.generate(
          2,
          (index) => [
            (edge.start.colors.lastOrNull ?? Colors.white).withValues(alpha: hoverOpacity),
            (edge.end?.colors.lastOrNull ?? Colors.white).withValues(alpha: hoverOpacity)
          ][index],
        ),
      );
    } else {
      paint.shader = ui.Gradient.linear(
        startPoint,
        endPoint,
        List.generate(
          2,
          (index) => [
            edge.start.colors.lastOrNull ?? Colors.white,
            (edge.end?.colors.lastOrNull ?? Colors.white)
          ][index],
        ),
      );
    }
    return paint;
  }

  @override
  double height(Edge edge) {
    return 3.0;
  }
}
