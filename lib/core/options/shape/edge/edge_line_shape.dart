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
    if (edge.start != edge.end) {
      vertexDifferent(edge, canvas, paint);
    } else {
      vertexSame(edge, canvas, paint);
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
      computeIndex(edge) * distance / edgesBetweenTwoVertex.length * 2,
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
    Path path = Path();
    var idx = edgeIdx(edge);
    var radius = (idx + 1) * edge.start.radius * 1.5;
    path.addArc(
      Rect.fromCircle(center: Offset(radius, 0), radius: radius),
      0,
      -2 * pi,
    );
    canvas.drawPath(path, paint);
    edge.path = path;
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
  hoverTest(Vector2 point, Edge edge, EdgeComponent edgeComponent) {
    Offset offset = Offset(
      (edge.end == null
              ? edge.start.cpn!.position.x
              : edge.end!.cpn!.position.x) -
          (edge.start.cpn!.position.x),
      (edge.end == null
              ? edge.start.cpn!.position.y
              : edge.end!.cpn!.position.y) -
          (edge.start.cpn!.position.y),
    );

    Offset offsetMouse = Offset(
      point.x - (edge.start.cpn!.position.x),
      point.y - (edge.start.cpn!.position.y),
    );

    double alpha = offsetMouse.direction - offset.direction;
    var distance = Util.distance(edge.cpn!.position, point);

    var relativePoint = Offset(
      distance * cos(alpha),
      distance * sin(alpha),
    );
    var idx = computeIndex(edge);
    return idx == 0
        ? null
        : (edge.path?.contains(relativePoint) ?? false) &&
            (!(edge.path
                    ?.shift(Offset(0, idx < 0 ? 4 : -4))
                    .contains(relativePoint) ??
                false));
  }

  int edgeIdx(Edge edge) {
    var edgeList =
        edge.cpn?.graph.edgesFromTwoVertex(edge.start, edge.end) ?? [];
    var idx = edgeList.indexOf(edge);
    return idx;
  }

  double computeIndex(Edge edge) {
    var edgeList =
        edge.cpn?.graph.edgesFromTwoVertex(edge.start, edge.end) ?? [];
    var idx = edgeList.indexOf(edge);
    if (edgeList.length.isOdd) {
      if (idx == 0) {
        return 0;
      } else if (idx.isEven) {
        return idx / 2;
      } else {
        return -(idx + 1) / 2;
      }
    } else {
      if (idx.isEven) {
        return idx / 2;
      } else {
        return -(idx - 1) / 2;
      }
    }
  }
}
