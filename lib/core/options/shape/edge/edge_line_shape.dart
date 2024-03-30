// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_graph_view/core/util.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

/// The default edge shape impl.
///
/// 默认使用 直线做边。
class EdgeLineShape extends EdgeShape {
  @override
  render(Edge edge, Canvas canvas, Paint paint, List<Paint> paintLayers) {
    if (edge.isLoop) {
      vertexSame(edge, canvas, paint);
    } else {
      vertexDifferent(edge, canvas, paint);
    }
  }

  void vertexDifferent(Edge edge, ui.Canvas canvas, ui.Paint paint) {
    var startPoint = Offset.zero;
    var endPoint = Offset(len(edge), paint.strokeWidth);

    var distance = Util.distance(edge.cpn!.position, edge.end!.position);

    var edgesBetweenTwoVertex =
        edge.cpn?.graph.edgesFromTwoVertex(edge.start, edge.end) ?? [];

    /// 法线点
    var normalPoint = Vector2(
      distance / 2,
      edge.computeIndex * distance / edgesBetweenTwoVertex.length * 2,
    );

    Path path = Path();
    path.cubicTo(
      startPoint.dx,
      startPoint.dy,
      normalPoint.x,
      normalPoint.y,
      endPoint.dx,
      endPoint.dy,
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

  Path loopPath(Edge edge, [double minusRadius = 0]) {
    var idx = edge.edgeIdx;
    var radius = (idx + 1) * edge.start.radius * 1.5;
    Path path = Path();
    path.addArc(
      Rect.fromCircle(
          center: Offset(radius, 0),
          radius: radius - minusRadius / edge.cpn!.game.camera.viewfinder.zoom),
      0,
      -2 * pi,
    );

    return path;
  }

  @override
  void setPaint(Edge edge) {
    var paint = edge.cpn!.paint;
    paint.strokeWidth = edge.isHovered ? 4 : 1.2;
    paint.strokeWidth /= edge.cpn!.game.camera.viewfinder.zoom;
    paint.style = PaintingStyle.stroke;
    var startPoint = Offset.zero;
    var endPoint = Offset(len(edge), paint.strokeWidth);
    if (isWeaken(edge)) {
      paint.shader = ui.Gradient.linear(
        startPoint,
        endPoint,
        List.generate(
          2,
          (index) => [
            (edge.start.colors.last).withOpacity(.5),
            (edge.end?.colors.last ?? Colors.white).withOpacity(.5)
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
            edge.start.colors.last,
            (edge.end?.colors.last ?? Colors.white)
          ][index],
        ),
      );
    }
  }

  @override
  double height(Edge edge) {
    return 3.0;
  }

  @override
  ShapeHitbox? hitBox(Edge edge, EdgeComponent edgeComponent) {
    return null;
  }

  @override
  bool? hoverTest(Vector2 point, Edge edge, EdgeComponent edgeComponent) {
    var offset = Offset(point.x, point.y);
    var hoverStrokeWidth = (edge.isHovered ? 2.0 : 1.2);
    if (edge.isLoop) {
      return edge.path!.contains(offset) &&
          !loopPath(edge, hoverStrokeWidth).contains(offset);
    } else {
      if (edge.computeIndex == 0) {
        return null;
      }
      Path? minusArea = edge.path?.shift(Offset(
        0,
        edge.computeIndex > 0 ? -hoverStrokeWidth : hoverStrokeWidth,
      ));
      return ((edge.path?.contains(offset) ?? false) &&
          (!(minusArea?.contains(offset) ?? true)));
    }
  }
}
