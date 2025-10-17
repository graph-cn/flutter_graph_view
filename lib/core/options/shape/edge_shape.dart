// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:math';
import 'dart:ui';

import 'package:flutter/rendering.dart' as r;
import 'package:flutter_graph_view/core/util.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart' hide Vector3;
import 'package:vector_math/vector_math_64.dart' hide Vector2;

/// Used to customize the edge UI.
///
/// 用于自定义边的UI
abstract class EdgeShape {
  List<EdgeDecorator>? decorators;
  EdgeShape({this.decorators});

  /// render the edge shape to canvas by data.
  ///
  /// 通过边数据将自定义的图形绘制到画布中。
  render(Edge edge, Canvas canvas, Paint paint, List<Paint> paintLayers);

  /// compute the width of the shape from data, used for overlap and mouse event judgment.
  ///
  /// 通过数据来计算形状的宽，用于重叠与鼠标事件判断。
  double width(Edge edge) {
    return len(edge);
  }

  /// compute the height of the shape from data, used for overlap and mouse event judgment.
  ///
  /// 通过数据计算形状的高，用于重叠与鼠标事件判断。
  double height(Edge edge);

  /// compute the size of the shape from data, used for overlap and mouse event judgment.
  ///
  /// 通过数据计算形状的尺寸，用于重叠与鼠标事件判断。
  Vector2 size(Edge edge) {
    return Vector2(width(edge), height(edge));
  }

  /// update the paint from data.
  ///
  /// 根据数据更新画笔属性。
  Paint getPaint(Edge edge);

  r.Matrix4 transformMatrix(Edge edge, Paint p) {
    var start = edge.start.position;
    var end = edge.end!.position;
    r.Matrix4 transformMatrix = r.Matrix4.identity();
    // 假设我们进行了一系列变换，这里我们记录下这些变换
    // 例如：先平移(100,100)，再旋转45度，再平移(50,50)
    transformMatrix.translateByVector3(Vector3(start.x, start.y, 0));
    var scale = 1;
    final angle = atan2(
      end.y - start.y,
      end.x - start.x,
    );
    transformMatrix.rotateZ(angle); // 旋转角度转换为弧度
    transformMatrix
        .translateByVector3(Vector3(0, -p.strokeWidth / scale / 2, 0));
    return transformMatrix;
  }

  bool? hoverTest(Vector2 position, Edge edge, r.Matrix4 transformMatrix,
      double hoverStrokeWidth) {
    var local = edge.g!.options!.globalToLocal(position);
    if (edge.isLoop) {
      return hoverByPath(local, edge.path!, transformMatrix) &&
          !hoverByPath(
              local, loopPath(edge, hoverStrokeWidth), transformMatrix);
    } else {
      if (edge.computeIndex == 0) {
        return hoverByPath(local, edge.path!, transformMatrix);
      }
      Path? minusArea = edge.path?.shift(Offset(
        0,
        edge.computeIndex > 0 ? -hoverStrokeWidth : hoverStrokeWidth,
      ));
      return (hoverByPath(local, edge.path!, transformMatrix) &&
          (!hoverByPath(local, minusArea!, transformMatrix)));
    }
  }

  bool hoverByPath(Vector2 local, Path path, r.Matrix4 transformMatrix) {
    final inverseMatrix = r.Matrix4.tryInvert(transformMatrix);
    if (inverseMatrix == null) {
      // 如果矩阵不可逆，则返回false
      return false;
    }
    // 将局部坐标应用逆变换，得到在画布变换前的坐标系中的坐标
    final transformedPosition =
        r.MatrixUtils.transformPoint(inverseMatrix, local.toOffset());
    // 判断变换后的坐标是否在原始的Path上
    return path.contains(transformedPosition) == true;
  }

  /// When some elements are activated and do not contain the current element.
  ///
  /// 当一些元素被激活且不包含当前元素
  bool isWeaken(Edge edge) {
    var graph = edge.g!;
    var isHoverVertexEdge = graph.hoverVertex != null &&
        !graph.hoverVertex!.neighborEdges.contains(edge);
    var isHoverEdge = graph.hoverEdge != null && graph.hoverEdge != edge;
    return isHoverVertexEdge || isHoverEdge;
  }

  /// Compute the line length by two vertex.
  ///
  /// 通过两个节点的坐标，计算线的长度。
  static double len(Edge edge) => edge.end == null
      ? 10
      : Util.distance(edge.start.position, edge.end!.position);

  /// Compute the shape angle by two vertex.
  ///
  /// 通过两个节点的坐标，获取线的旋转角度
  double angle(Edge edge) {
    Offset offset = Offset(
      (edge.end == null ? edge.start.position.x : edge.end!.position.x) -
          (edge.start.position.x),
      (edge.end == null ? edge.start.position.y : edge.end!.position.y) -
          (edge.start.position.y),
    );

    return offset.direction;
  }

  Path loopPath(Edge edge, [double minusRadius = 0]) {
    var ratio = edge.edgeIdxRatio;
    var radius = ratio * edge.start.radius * 5 + edge.start.radiusZoom;
    Path path = Path();
    path.addArc(
      Rect.fromCircle(
          center: Offset(radius, 0), radius: radius - minusRadius / edge.zoom),
      0,
      -2 * pi,
    );

    return path;
  }
}
