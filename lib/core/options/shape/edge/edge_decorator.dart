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

/// 线尾实心箭头
class SolidArrowEdgeDecorator extends DefaultEdgeDecorator {
  double arrowBaseDistance; // 箭头长度
  double arrowWidth; // 箭头宽度

  SolidArrowEdgeDecorator({
    this.arrowBaseDistance = 10.0,
    this.arrowWidth = 3.0,
  });

  @override
  void decorate(
    Edge edge,
    Canvas canvas,
    Paint paint,
    double distance,
    int edgeCount,
  ) {
    // 边线已经由EdgeLineShape绘制，这里只添加箭头
    drawArrowOnEdge(edge, canvas, paint);
  }

  void drawArrowOnEdge(Edge edge, Canvas canvas, Paint paint) {
    // 箭头目标点（边的终点）
    var end = dstPosition(edge);

    // 确定箭头的方向向量
    Vector2 directionVector;

    if (edge.isLoop) {
      // 自环情况下，箭头方向是圆弧切线
      // var ratio = edge.edgeIdxRatio;
      // var radius = ratio * edge.start.radius * 5 + edge.start.radiusZoom;
      // 箭头位置（在圆环上的顶部）
      // var arrowPos = Vector2(radius, -radius);
      // 自环的切线方向（水平向左）
      directionVector = Vector2(-1, 0);
    } else if (edge.path != null) {
      // 对于一般曲线，使用曲线路径计算切线方向
      // 为简化，我们可以假设边的末端点接近目标节点

      // 获取路径上接近末端的一个点，用于估算切线
      var pathMetric = edge.path!.computeMetrics().first;
      var pathLength = pathMetric.length;
      // 获取曲线末端附近的点（比如最后0.5%的位置）
      var tangentPos = pathLength * 0.995;
      var tangent = pathMetric.getTangentForOffset(tangentPos);

      if (tangent != null) {
        // 使用路径切线作为方向向量
        directionVector =
            Vector2(tangent.vector.dx, tangent.vector.dy).normalized();
      } else {
        // 如果无法获取切线，回退到直线方式
        var start = srcPosition(edge);
        directionVector = (end - start).normalized();
      }
    } else {
      // 直线情况
      var start = srcPosition(edge);
      directionVector = (end - start).normalized();
    }

    // 计算箭头尖端位置（考虑目标节点半径）
    var tipPoint = end - directionVector * edge.end!.radiusZoom;

    // 计算线宽调整系数
    double strokeWidthFactor =
        (edge.isHovered ? 2.0 : 1.0) / edge.start.zoom; // 悬停时线宽增加的比例

    // 基于当前线宽计算箭头尺寸
    double currentArrowBaseDistance = arrowBaseDistance * strokeWidthFactor;
    double currentArrowWidth = arrowWidth * strokeWidthFactor;

    // 计算箭头基部位置，考虑悬停状态的影响
    var basePoint = tipPoint - directionVector * currentArrowBaseDistance;

    if (tipPoint.isNaN || basePoint.isNaN) {
      return;
    }

    // 计算垂直于方向向量的向量，用于箭头两侧
    // 不再需要额外的悬停修正系数，因为已经在currentArrowWidth中处理
    var perp =
        Vector2(-directionVector.y, directionVector.x) * currentArrowWidth;

    // 创建并填充箭头路径
    var path = Path()
      ..moveTo(tipPoint.x, tipPoint.y) // 箭头尖端
      ..lineTo(basePoint.x + perp.x, basePoint.y + perp.y) // 箭头左侧
      ..lineTo(basePoint.x - perp.x, basePoint.y - perp.y) // 箭头右侧
      ..close();

    // 创建填充画笔（确保是填充的）
    var arrowPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;
    if (paint.shader != null) {
      arrowPaint.shader = paint.shader;
    }

    // 绘制实心箭头
    canvas.drawPath(path, arrowPaint);
  }
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
    if (srcToEndJ.isNaN || srcToEndI.isNaN) {
      return;
    }
    canvas.drawLine(srcToEndI.toOffset(), srcToEndJ.toOffset(), paint);
  }

  Vector2 srcPosition(Edge edge) {
    return Vector2(0, edge.cpn!.size.y / 2);
  }

  Vector2 dstPosition(Edge edge) {
    return Vector2(EdgeShape.len(edge), edge.cpn!.size.y / 2);
  }
}
