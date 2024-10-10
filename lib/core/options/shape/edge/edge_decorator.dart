// Copyright (c) 2024- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:ui';

import 'package:flutter_graph_view/flutter_graph_view.dart';

abstract class EdgeDecorator {
  decorate(
    Edge edge,
    Canvas canvas,
    Paint paint,
    double distance,
    int edgeCount,
  );
}

class DefaultEdgeDecorator extends EdgeDecorator {
  @override
  void decorate(
    Edge edge,
    Canvas canvas,
    Paint paint,
    double distance,
    int edgeCount,
  ) {
    var f =
        0.35 * (edge.computeIndex.abs() + 1) / (edge.computeIndex.abs() + 2);
    var n1 = Vector2(
      distance / 2,
      (edge.computeIndex + f) * distance / edgeCount * 2 + edge.cpn!.size.y / 2,
    );
    drawArrow(edge, canvas, paint, n1);

    var n2 = Vector2(
      distance / 2,
      (edge.computeIndex - f) * distance / edgeCount * 2 + edge.cpn!.size.y / 2,
    );
    drawArrow(edge, canvas, paint, n2);
  }

  void drawArrow(Edge edge, Canvas canvas, Paint paint, Vector2 normalPoint) {
    var end = dstPosition(edge);
    var nToEnd = end - normalPoint;
    var arrowBaseLineLength = nToEnd.length;
    // 根据end半径，计算交接点坐标
    var i = nToEnd * (edge.end!.radiusZoom / arrowBaseLineLength);
    var j = nToEnd * ((edge.end!.radiusZoom + 10) / arrowBaseLineLength);
    var srcToEndI = end - i;
    var srcToEndJ = end - j;

    canvas.drawLine(srcToEndI.toOffset(), srcToEndJ.toOffset(), paint);
  }

  Vector2 srcPosition(Edge edge) {
    return Vector2(0, edge.cpn!.size.y / 2);
  }

  Vector2 dstPosition(Edge edge) {
    return Vector2(EdgeShape.len(edge), edge.cpn!.size.y / 2);
  }
}
